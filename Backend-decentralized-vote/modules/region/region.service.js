// ============================================================================
// VoteSecure — Region Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes, CacheTTL } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import { getRedisClient as getRedis } from "../../services/redis.service.js";

const log = createLogger("RegionService");

export async function listRegions(countryCode) {
  const redis = getRedis();
  const cacheKey = `regions:${countryCode || "all"}`;
  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const where = countryCode ? { countryCode: countryCode.toUpperCase(), isActive: true } : { isActive: true };
  const regions = await prisma.region.findMany({ where, orderBy: { name: "asc" } });

  if (redis) await redis.setex(cacheKey, CacheTTL.REGION_LIST, JSON.stringify(regions));
  return regions;
}

export async function getRegionById(regionId) {
  const region = await prisma.region.findUnique({
    where: { id: regionId },
    include: { _count: { select: { users: true, elections: true } } },
  });
  if (!region) throw new AppError("Region not found", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);
  return region;
}

export async function createRegion({ name, countryCode, stateCode, level, geoJson }) {
  const existing = await prisma.region.findFirst({
    where: { name, countryCode: countryCode.toUpperCase(), stateCode },
  });
  if (existing) throw new AppError("Region already exists", HttpStatus.CONFLICT, ErrorCodes.USER_ALREADY_EXISTS);

  const region = await prisma.region.create({
    data: { name, countryCode: countryCode.toUpperCase(), stateCode, level, geoJson },
  });

  // Invalidate cache
  const redis = getRedis();
  if (redis) {
    await redis.del(`regions:all`);
    await redis.del(`regions:${countryCode.toUpperCase()}`);
  }

  log.info(`Region created: ${region.id}`);
  return region;
}

export async function updateRegion({ regionId, ...updates }) {
  const region = await prisma.region.findUnique({ where: { id: regionId } });
  if (!region) throw new AppError("Region not found", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);
  return prisma.region.update({ where: { id: regionId }, data: updates });
}

export async function assignVoterToRegion({ regionId, userId }) {
  const region = await prisma.region.findUnique({ where: { id: regionId } });
  if (!region || !region.isActive) throw new AppError("Region not found or inactive", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);

  return prisma.user.update({ where: { id: userId }, data: { regionId } });
}

export async function getElectionsByRegion(regionId) {
  const region = await prisma.region.findUnique({ where: { id: regionId } });
  if (!region) throw new AppError("Region not found", HttpStatus.NOT_FOUND, ErrorCodes.REGION_NOT_FOUND);

  return prisma.election.findMany({
    where: { regionId },
    orderBy: { startDate: "desc" },
    select: { id: true, title: true, type: true, status: true, startDate: true, endDate: true },
  });
}
