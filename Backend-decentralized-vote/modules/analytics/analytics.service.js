// ============================================================================
// VoteSecure — Analytics Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { createLogger } from "../../logs/logger.js";
import { getRedisClient as getRedis } from "../../services/redis.service.js";
import { CacheTTL } from "../../config/constants.js";

const log = createLogger("AnalyticsService");

export async function getElectionAnalytics(electionId) {
  const redis = getRedis();
  const cacheKey = `analytics:election:${electionId}`;
  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const [election, totalVotes, candidateStats, forumStats, fraudStats] = await Promise.all([
    prisma.election.findUnique({ where: { id: electionId }, include: { region: true } }),
    prisma.vote.count({ where: { electionId } }),
    prisma.candidate.findMany({
      where: { electionId, status: "APPROVED" },
      select: { id: true, totalVotesFor: true, slaBreaches: true, user: { select: { displayName: true } } },
      orderBy: { totalVotesFor: "desc" },
    }),
    prisma.forumPost.groupBy({ by: ["status"], where: { electionId }, _count: true }),
    prisma.fraudReport.count({ where: { electionId } }),
  ]);

  const result = {
    electionId,
    title: election?.title,
    status: election?.status,
    region: election?.region?.name,
    totalVotes,
    totalCandidates: candidateStats.length,
    candidateBreakdown: candidateStats,
    forumBreakdown: forumStats,
    fraudReports: fraudStats,
    turnoutPct: election ? ((totalVotes / Math.max(election.totalVotes, totalVotes, 1)) * 100).toFixed(2) : null,
  };

  if (redis) await redis.setex(cacheKey, CacheTTL.ANALYTICS, JSON.stringify(result));
  return result;
}

export async function getPlatformStats() {
  const redis = getRedis();
  const cacheKey = "analytics:platform";
  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const [totalUsers, verifiedVoters, activeElections, totalVotes, totalParties, totalRegions, totalFraudReports] =
    await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { kycStatus: { in: ["BIOMETRIC_VERIFIED", "FULLY_VERIFIED"] } } }),
      prisma.election.count({ where: { status: "ACTIVE" } }),
      prisma.vote.count(),
      prisma.party.count({ where: { status: "ACTIVE" } }),
      prisma.region.count({ where: { isActive: true } }),
      prisma.fraudReport.count({ where: { status: "CONFIRMED" } }),
    ]);

  const stats = { totalUsers, verifiedVoters, activeElections, totalVotes, totalParties, totalRegions, confirmedFraud: totalFraudReports };

  if (redis) await redis.setex(cacheKey, CacheTTL.ANALYTICS, JSON.stringify(stats));
  return stats;
}

export async function getVoterTurnoutByRegion(electionId) {
  const votes = await prisma.vote.findMany({
    where: { electionId },
    include: { voter: { select: { regionId: true, region: { select: { name: true } } } } },
  });

  const regionMap = {};
  for (const vote of votes) {
    const key = vote.voter.region?.name || "Unknown";
    regionMap[key] = (regionMap[key] || 0) + 1;
  }

  return Object.entries(regionMap).map(([region, count]) => ({ region, count })).sort((a, b) => b.count - a.count);
}
