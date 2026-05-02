// ============================================================================
// VoteSecure — Admin Module
// Platform-wide administrative operations
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import { autoBanUser } from "../fraud/fraud.service.js";
import admin from "../../config/firebase-admin.config.js";

const log = createLogger("AdminService");

export async function listUsers({ page = 1, limit = 20, role, kycStatus, isBanned, search }) {
  const skip = (page - 1) * limit;
  const where = {};
  if (role) where.role = role;
  if (kycStatus) where.kycStatus = kycStatus;
  if (typeof isBanned === "boolean") where.isBanned = isBanned;
  if (search) {
    where.OR = [
      { email: { contains: search, mode: "insensitive" } },
      { displayName: { contains: search, mode: "insensitive" } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true, email: true, displayName: true, role: true, kycStatus: true,
        isBanned: true, createdAt: true, regionId: true, walletAddress: true,
      },
    }),
    prisma.user.count({ where }),
  ]);

  return { data, total, page, limit };
}

export async function setUserRole({ adminId, userId, role }) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);

  const updated = await prisma.user.update({ where: { id: userId }, data: { role } });
  log.info(`Role set: ${userId} → ${role} by admin ${adminId}`);
  return updated;
}

export async function banUser({ adminId, userId, reason }) {
  return autoBanUser({ userId, reason: `Admin ban by ${adminId}: ${reason}` });
}

export async function unbanUser({ adminId, userId }) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);

  const updated = await prisma.user.update({
    where: { id: userId },
    data: { isBanned: false, banReason: null, bannedAt: null, bannedBy: null },
  });

  log.info(`User unbanned: ${userId} by admin ${adminId}`);
  return updated;
}

export async function getPlatformOverview() {
  const [users, elections, votes, parties, regions, fraudReports] = await Promise.all([
    prisma.user.groupBy({ by: ["role"], _count: true }),
    prisma.election.groupBy({ by: ["status"], _count: true }),
    prisma.vote.count(),
    prisma.party.groupBy({ by: ["status"], _count: true }),
    prisma.region.count({ where: { isActive: true } }),
    prisma.fraudReport.groupBy({ by: ["status"], _count: true }),
  ]);

  return { users, elections, votes, parties, regions, fraudReports };
}

export async function broadcastSystemNotification({ adminId, title, body, type = "GENERAL" }) {
  // Get all active users with FCM tokens
  const users = await prisma.user.findMany({
    where: { isActive: true, isBanned: false, fcmToken: { not: null } },
    select: { id: true, fcmToken: true },
  });

  const tokens = users.map((u) => u.fcmToken).filter(Boolean);

  if (tokens.length > 0) {
    try {
      // FCM batch limit is 500
      const batches = [];
      for (let i = 0; i < tokens.length; i += 500) {
        batches.push(tokens.slice(i, i + 500));
      }
      for (const batch of batches) {
        await admin.messaging().sendEachForMulticast({ tokens: batch, notification: { title, body } });
      }
    } catch (err) {
      log.warn("Broadcast FCM failed", { error: err.message });
    }
  }

  log.info(`System broadcast sent by admin ${adminId}: ${title}`);
  return { sent: tokens.length };
}
