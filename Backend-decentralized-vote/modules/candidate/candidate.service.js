// ============================================================================
// VoteSecure — Candidate Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import {
  registerCandidateOnChain,
  approveCandidateOnChain,
  disqualifyCandidateOnChain,
} from "../../services/blockchain/blockchain.service.js";

const log = createLogger("CandidateService");

export async function registerCandidate({ userId, electionId, partyId, regionId, profileBio, manifestoUrl, achievements, milestones, lifeSummary, payoutAddress }) {
  // Check election exists and accepts candidates
  const election = await prisma.election.findUnique({ where: { id: electionId } });
  if (!election) throw new AppError("Election not found", HttpStatus.NOT_FOUND, ErrorCodes.ELECTION_NOT_FOUND);

  const now = new Date();
  if (election.registrationEnd && now > election.registrationEnd) {
    throw new AppError("Candidate registration is closed", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.ELECTION_REGISTRATION_CLOSED);
  }

  if (!["DRAFT", "PENDING", "ACTIVE"].includes(election.status)) {
    throw new AppError("Cannot register for this election", HttpStatus.UNPROCESSABLE_ENTITY, ErrorCodes.ELECTION_PHASE_ERROR);
  }

  // Validate max candidates
  const currentCount = await prisma.candidate.count({ where: { electionId } });
  if (currentCount >= election.maxCandidates) {
    throw new AppError("Election candidate limit reached", HttpStatus.CONFLICT, ErrorCodes.DUPLICATE_CANDIDATE_ENTRY);
  }

  // Check not already registered
  const existing = await prisma.candidate.findFirst({ where: { userId, electionId } });
  if (existing) {
    throw new AppError("Already registered as candidate in this election", HttpStatus.CONFLICT, ErrorCodes.DUPLICATE_CANDIDATE_ENTRY);
  }

  // Validate party if provided
  if (partyId) {
    const party = await prisma.party.findUnique({ where: { id: partyId } });
    if (!party || party.status !== "ACTIVE") {
      throw new AppError("Party not found or not active", HttpStatus.BAD_REQUEST, ErrorCodes.PARTY_NOT_ACTIVE);
    }
  }

  const candidate = await prisma.candidate.create({
    data: {
      userId,
      electionId,
      partyId,
      regionId,
      profileBio,
      manifestoUrl,
      achievements,
      milestones,
      lifeSummary,
      payoutAddress,
      status: "PENDING",
    },
    include: {
      user: { select: { id: true, displayName: true, email: true, avatarUrl: true, walletAddress: true } },
      party: { select: { id: true, name: true, logoUrl: true } },
    },
  });

  // Register on-chain (async, non-blocking)
  if (candidate.user.walletAddress) {
    registerCandidateOnChain({
      electionId: election.onChainId || electionId,
      candidateId: candidate.id,
      walletAddress: candidate.user.walletAddress,
      partyId,
    }).catch((err) => log.warn("On-chain candidate registration failed", { error: err.message }));
  }

  log.info(`Candidate registered: ${candidate.id} in election ${electionId}`);
  return candidate;
}

export async function getCandidatesByElection(electionId, status) {
  const where = { electionId };
  if (status) where.status = status;

  return prisma.candidate.findMany({
    where,
    include: {
      user: { select: { id: true, displayName: true, avatarUrl: true } },
      party: { select: { id: true, name: true, logoUrl: true, ideology: true } },
    },
    orderBy: { popularityScore: "desc" },
  });
}

export async function getCandidateById(candidateId) {
  const candidate = await prisma.candidate.findUnique({
    where: { id: candidateId },
    include: {
      user: { select: { id: true, displayName: true, email: true, avatarUrl: true } },
      party: true,
      election: { select: { id: true, title: true, status: true } },
      forumAnswers: { include: { post: { select: { id: true, content: true } } }, orderBy: { createdAt: "desc" }, take: 10 },
    },
  });
  if (!candidate) throw new AppError("Candidate not found", HttpStatus.NOT_FOUND, ErrorCodes.CANDIDATE_NOT_FOUND);
  return candidate;
}

export async function updateCandidateProfile({ candidateId, userId, ...updates }) {
  const candidate = await prisma.candidate.findUnique({ where: { id: candidateId } });
  if (!candidate) throw new AppError("Candidate not found", HttpStatus.NOT_FOUND, ErrorCodes.CANDIDATE_NOT_FOUND);
  if (candidate.userId !== userId) throw new AppError("Not authorized", HttpStatus.FORBIDDEN, ErrorCodes.FORBIDDEN);

  return prisma.candidate.update({
    where: { id: candidateId },
    data: updates,
  });
}

export async function approveCandidate({ adminId, candidateId, action, reason }) {
  const candidate = await prisma.candidate.findUnique({
    where: { id: candidateId },
    include: { user: { select: { walletAddress: true } } },
  });
  if (!candidate) throw new AppError("Candidate not found", HttpStatus.NOT_FOUND, ErrorCodes.CANDIDATE_NOT_FOUND);

  const statusMap = { approve: "APPROVED", reject: "REJECTED", disqualify: "DISQUALIFIED" };
  const newStatus = statusMap[action];
  if (!newStatus) throw new AppError("Invalid action", HttpStatus.BAD_REQUEST, ErrorCodes.INVALID_INPUT);

  const updated = await prisma.candidate.update({
    where: { id: candidateId },
    data: {
      status: newStatus,
      approvedBy: adminId,
      approvedAt: newStatus === "APPROVED" ? new Date() : null,
      disqualifyReason: ["REJECTED", "DISQUALIFIED"].includes(newStatus) ? reason : null,
    },
  });

  // Sync on-chain
  if (newStatus === "APPROVED" && candidate.user.walletAddress) {
    approveCandidateOnChain({ electionId: candidate.electionId, candidateId })
      .catch((err) => log.warn("On-chain approval failed", { error: err.message }));
  }
  if (newStatus === "DISQUALIFIED" && reason) {
    disqualifyCandidateOnChain({ electionId: candidate.electionId, candidateId, reason })
      .catch((err) => log.warn("On-chain disqualification failed", { error: err.message }));
  }

  log.info(`Candidate ${candidateId} → ${newStatus} by admin ${adminId}`);
  return updated;
}
