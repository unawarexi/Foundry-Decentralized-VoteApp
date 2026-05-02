// ============================================================================
// VoteSecure — Vote Service
// Orchestrates vote flow: verify → check eligibility → on-chain → record
// ============================================================================

import { ethers } from "ethers";
import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import {
  castVoteOnChain,
  isNullifierUsed,
  isVoterRegistered,
  isVoterBanned,
} from "../../services/blockchain/blockchain.service.js";
import { verifyVoteFeePayment, recordTransaction } from "../../services/payment/payment.service.js";
import { aiRequest } from "../../services/ai-gateway.service.js";
import { getRedisClient as getRedis } from "../../services/redis.service.js";

const log = createLogger("VoteService");

// ============================================================================
// CAST VOTE — Full orchestration
// ============================================================================

export async function castVote({ voterId, electionId, candidateId, nullifierHash, zkProof, feeToken, txHash }) {
  // 1. Load voter
  const voter = await prisma.user.findUnique({
    where: { id: voterId },
    include: { region: true },
  });
  if (!voter) throw new AppError("Voter not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);
  if (voter.isBanned) throw new AppError("Voter is banned", HttpStatus.FORBIDDEN, ErrorCodes.VOTER_BANNED);
  if (voter.kycStatus === "NONE" || voter.kycStatus === "EMAIL_VERIFIED") {
    throw new AppError("KYC verification required to vote", HttpStatus.FORBIDDEN, ErrorCodes.KYC_REQUIRED);
  }

  // 2. Load election
  const election = await prisma.election.findUnique({ where: { id: electionId } });
  if (!election) throw new AppError("Election not found", HttpStatus.NOT_FOUND, ErrorCodes.ELECTION_NOT_FOUND);
  if (election.status !== "ACTIVE") {
    throw new AppError("Election is not active", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.ELECTION_NOT_ACTIVE);
  }

  const now = new Date();
  if (now < election.startDate || now > election.endDate) {
    throw new AppError("Election is not currently open for voting", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.ELECTION_NOT_ACTIVE);
  }

  // 3. Region lock check
  if (election.regionId && voter.regionId !== election.regionId) {
    throw new AppError(
      "You are not registered in the correct region for this election",
      HttpStatus.FORBIDDEN,
      ErrorCodes.REGION_MISMATCH
    );
  }

  // 4. Validate candidate
  const candidate = await prisma.candidate.findUnique({ where: { id: candidateId } });
  if (!candidate || candidate.electionId !== electionId || candidate.status !== "APPROVED") {
    throw new AppError("Invalid or unapproved candidate", HttpStatus.BAD_REQUEST, ErrorCodes.INVALID_CANDIDATE);
  }

  // 5. Check for double vote (DB level)
  const existingVote = await prisma.vote.findFirst({
    where: { electionId, voterId },
  });
  if (existingVote) {
    throw new AppError("You have already voted in this election", HttpStatus.CONFLICT, ErrorCodes.ALREADY_VOTED);
  }

  // 6. Check nullifier not already used on-chain
  try {
    const nullifierUsed = await isNullifierUsed(nullifierHash);
    if (nullifierUsed) {
      throw new AppError("Nullifier hash already used", HttpStatus.CONFLICT, ErrorCodes.NULLIFIER_ALREADY_USED);
    }
  } catch (err) {
    if (err.code === ErrorCodes.NULLIFIER_ALREADY_USED) throw err;
    log.warn("Could not check nullifier on-chain", { error: err.message });
  }

  // 7. Check on-chain voter ban
  if (voter.walletAddress) {
    try {
      const banned = await isVoterBanned(voter.walletAddress);
      if (banned) throw new AppError("Voter is banned on-chain", HttpStatus.FORBIDDEN, ErrorCodes.VOTER_BANNED);
    } catch (err) {
      if (err.code === ErrorCodes.VOTER_BANNED) throw err;
      log.warn("Could not check on-chain ban status", { error: err.message });
    }
  }

  // 8. AI fraud check (via FastAPI)
  try {
    const aiResult = await aiRequest("POST", "/fraud/check-vote", {
      voterId,
      electionId,
      walletAddress: voter.walletAddress,
      ipAddress: null, // passed from request context ideally
    });
    if (aiResult?.blocked) {
      throw new AppError("Vote blocked by fraud detection", HttpStatus.FORBIDDEN, ErrorCodes.FRAUD_FLAG_SUBMITTED);
    }
  } catch (err) {
    if ([ErrorCodes.FRAUD_FLAG_SUBMITTED].includes(err.code)) throw err;
    log.warn("AI fraud check unavailable — proceeding", { error: err.message });
  }

  // 9. Record vote in DB first (optimistic)
  const vote = await prisma.vote.create({
    data: {
      electionId,
      voterId,
      nullifierHash,
      feeToken,
      feePaid: election.voteFeeCents / 100,
    },
  });

  // 10. Submit to blockchain
  let receipt;
  try {
    if (voter.walletAddress && election.onChainId) {
      receipt = await castVoteOnChain({
        electionId: election.onChainId,
        candidateId: candidate.id,
        nullifierHash,
        proof: zkProof ? Buffer.from(zkProof, "base64") : "0x",
        voteFeeWei: 0, // fee already confirmed via escrow
      });
    }
  } catch (err) {
    // Rollback DB vote if blockchain fails
    await prisma.vote.delete({ where: { id: vote.id } });
    log.error("On-chain vote failed — rolled back", { error: err.message });
    throw new AppError("Vote submission to blockchain failed", HttpStatus.INTERNAL_SERVER_ERROR, ErrorCodes.BLOCKCHAIN_TX_FAILED);
  }

  // 11. Update vote with tx hash + increment candidate tally
  const [updatedVote] = await Promise.all([
    prisma.vote.update({
      where: { id: vote.id },
      data: { txHash: receipt?.hash || txHash, blockNumber: receipt?.blockNumber ? BigInt(receipt.blockNumber) : null },
    }),
    prisma.candidate.update({
      where: { id: candidateId },
      data: { totalVotesFor: { increment: 1 } },
    }),
    prisma.election.update({
      where: { id: electionId },
      data: { totalVotes: { increment: 1 } },
    }),
  ]);

  // 12. Record payment transaction
  if (election.voteFeeCents > 0) {
    await recordTransaction({
      userId: voterId,
      electionId,
      type: "VOTE_FEE",
      amount: election.voteFeeCents / 100,
      token: feeToken,
      txHash: receipt?.hash || txHash,
      blockNumber: receipt?.blockNumber,
      status: "CONFIRMED",
    });
  }

  // 13. Invalidate caches
  const redis = getRedis();
  if (redis) {
    await redis.del(`election:${electionId}:results`);
    await redis.del(`election:${electionId}`);
  }

  log.info(`Vote cast: voter ${voterId} in election ${electionId}`);
  return {
    voteId: updatedVote.id,
    txHash: updatedVote.txHash,
    nullifierHash,
    electionId,
  };
}

// ============================================================================
// HAS VOTED
// ============================================================================

export async function hasVoted(voterId, electionId) {
  const vote = await prisma.vote.findFirst({
    where: { electionId, voterId },
    select: { id: true, nullifierHash: true, createdAt: true },
  });
  return vote;
}

// ============================================================================
// MY VOTES
// ============================================================================

export async function getMyVotes(voterId) {
  return prisma.vote.findMany({
    where: { voterId },
    include: {
      election: { select: { id: true, title: true, status: true, type: true } },
    },
    orderBy: { createdAt: "desc" },
  });
}
