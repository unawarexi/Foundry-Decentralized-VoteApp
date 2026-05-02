// ============================================================================
// VoteSecure — Election Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes, CacheTTL } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import { getRedisClient as getRedis } from "../../services/redis.service.js";
import {
  createElectionOnChain,
  finalizeElectionOnChain,
  getElectionStatusOnChain,
  getVoteTally,
} from "../../services/blockchain/blockchain.service.js";

const log = createLogger("ElectionService");

// ============================================================================
// LIST ELECTIONS (paginated + filtered)
// ============================================================================

export async function listElections({ page = 1, limit = 20, status, type, regionId, search } = {}) {
  const skip = (page - 1) * limit;

  const where = {};
  if (status) where.status = status;
  if (type) where.type = type;
  if (regionId) where.regionId = regionId;
  if (search) {
    where.title = { contains: search, mode: "insensitive" };
  }

  const [data, total] = await Promise.all([
    prisma.election.findMany({
      where,
      skip,
      take: limit,
      orderBy: { startDate: "desc" },
      include: {
        region: { select: { id: true, name: true, countryCode: true } },
        _count: { select: { candidates: true, votes: true } },
      },
    }),
    prisma.election.count({ where }),
  ]);

  return { data, total, page, limit };
}

// ============================================================================
// GET ACTIVE ELECTIONS
// ============================================================================

export async function getActiveElections(regionId) {
  const redis = getRedis();
  const cacheKey = `elections:active:${regionId || "all"}`;

  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const now = new Date();
  const where = {
    status: "ACTIVE",
    startDate: { lte: now },
    endDate: { gte: now },
  };

  if (regionId) where.regionId = regionId;

  const elections = await prisma.election.findMany({
    where,
    include: {
      region: true,
      _count: { select: { candidates: true, votes: true } },
    },
  });

  if (redis) await redis.setex(cacheKey, CacheTTL.ELECTION_LIST, JSON.stringify(elections));
  return elections;
}

// ============================================================================
// GET ELECTION BY ID
// ============================================================================

export async function getElectionById(electionId) {
  const redis = getRedis();
  const cacheKey = `election:${electionId}`;

  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const election = await prisma.election.findUnique({
    where: { id: electionId },
    include: {
      region: true,
      candidates: {
        where: { status: "APPROVED" },
        include: { user: { select: { id: true, displayName: true, avatarUrl: true } }, party: true },
        orderBy: { totalVotesFor: "desc" },
      },
      _count: { select: { votes: true, forumPosts: true } },
    },
  });

  if (!election) {
    throw new AppError("Election not found", HttpStatus.NOT_FOUND, ErrorCodes.ELECTION_NOT_FOUND);
  }

  if (redis && ["ACTIVE", "PAUSED", "TALLYING", "FINALIZED"].includes(election.status)) {
    await redis.setex(cacheKey, CacheTTL.ELECTION_DETAIL, JSON.stringify(election));
  }

  return election;
}

// ============================================================================
// CREATE ELECTION
// ============================================================================

export async function createElection({ adminId, title, description, type, regionId, startDate, endDate, registrationEnd, voteFeeCents, feeToken, minCandidates, maxCandidates }) {
  // Validate region exists
  const region = await prisma.region.findUnique({ where: { id: regionId } });
  if (!region) {
    throw new AppError("Region not found", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);
  }

  const election = await prisma.election.create({
    data: {
      title,
      description,
      type,
      regionId,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      registrationEnd: registrationEnd ? new Date(registrationEnd) : null,
      voteFeeCents,
      feeToken,
      minCandidates,
      maxCandidates,
      createdBy: adminId,
      status: "DRAFT",
    },
    include: { region: true },
  });

  log.info(`Election created: ${election.id} by admin ${adminId}`);
  return election;
}

// ============================================================================
// UPDATE ELECTION PHASE (admin)
// ============================================================================

export async function updateElectionPhase({ electionId, adminId, status, cancelReason }) {
  const election = await prisma.election.findUnique({ where: { id: electionId } });
  if (!election) {
    throw new AppError("Election not found", HttpStatus.NOT_FOUND, ErrorCodes.ELECTION_NOT_FOUND);
  }

  const validTransitions = {
    DRAFT: ["PENDING", "CANCELLED"],
    PENDING: ["ACTIVE", "CANCELLED"],
    ACTIVE: ["PAUSED", "TALLYING", "CANCELLED"],
    PAUSED: ["ACTIVE", "CANCELLED"],
    TALLYING: ["FINALIZED", "CANCELLED"],
  };

  const allowed = validTransitions[election.status] || [];
  if (!allowed.includes(status)) {
    throw new AppError(
      `Cannot transition election from ${election.status} to ${status}`,
      HttpStatus.UNPROCESSABLE_ENTITY,
      ErrorCodes.ELECTION_PHASE_ERROR
    );
  }

  const updateData = { status };
  if (status === "CANCELLED") {
    updateData.cancelReason = cancelReason || "Cancelled by admin";
    updateData.cancelledAt = new Date();
  }

  if (status === "FINALIZED") {
    // Trigger blockchain finalization
    try {
      if (election.onChainId) {
        await finalizeElectionOnChain(election.onChainId);
      }
    } catch (err) {
      log.warn("On-chain finalization failed", { error: err.message });
    }
    updateData.finalizedAt = new Date();
  }

  const updated = await prisma.election.update({
    where: { id: electionId },
    data: updateData,
  });

  // Invalidate cache
  const redis = getRedis();
  if (redis) {
    await redis.del(`election:${electionId}`);
    await redis.del(`elections:active:${election.regionId}`);
    await redis.del("elections:active:all");
  }

  log.info(`Election ${electionId} phase → ${status} by ${adminId}`);
  return updated;
}

// ============================================================================
// GET ELECTION RESULTS
// ============================================================================

export async function getElectionResults(electionId) {
  const election = await getElectionById(electionId);

  if (!["TALLYING", "FINALIZED"].includes(election.status)) {
    throw new AppError(
      "Results are only available after tallying",
      HttpStatus.FORBIDDEN,
      ErrorCodes.ELECTION_PHASE_ERROR
    );
  }

  const redis = getRedis();
  const cacheKey = `election:${electionId}:results`;

  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  // Get vote counts from DB (mirrors on-chain tally)
  const candidates = await prisma.candidate.findMany({
    where: { electionId, status: "APPROVED" },
    include: {
      user: { select: { id: true, displayName: true, avatarUrl: true } },
      party: { select: { id: true, name: true, logoUrl: true } },
    },
    orderBy: { totalVotesFor: "desc" },
  });

  const totalVotes = candidates.reduce((sum, c) => sum + c.totalVotesFor, 0);
  const results = {
    electionId,
    title: election.title,
    status: election.status,
    totalVotes,
    finalizedAt: election.finalizedAt,
    candidates: candidates.map((c) => ({
      id: c.id,
      name: c.user.displayName,
      avatar: c.user.avatarUrl,
      party: c.party?.name,
      votes: c.totalVotesFor,
      percentage: totalVotes > 0 ? ((c.totalVotesFor / totalVotes) * 100).toFixed(2) : "0.00",
    })),
  };

  if (redis && election.status === "FINALIZED") {
    await redis.setex(cacheKey, CacheTTL.ELECTION_RESULTS, JSON.stringify(results));
  }

  return results;
}

// ============================================================================
// GET ELECTIONS BY REGION
// ============================================================================

export async function getElectionsByRegion(regionId, query = {}) {
  const region = await prisma.region.findUnique({ where: { id: regionId } });
  if (!region) {
    throw new AppError("Region not found", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);
  }
  return listElections({ ...query, regionId });
}
