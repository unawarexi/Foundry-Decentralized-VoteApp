// ============================================================================
// VoteSecure — User Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";

const log = createLogger("UserService");

const USER_SELECT = {
  id: true, firebaseUid: true, email: true, displayName: true, avatarUrl: true,
  logoUrl: true, slogan: true, languages: true, religion: true, phone: true,
  role: true, kycStatus: true, isBanned: true, isActive: true, emailVerified: true,
  phoneVerified: true, identityHash: true, deviceId: true, fcmToken: true,
  regionId: true, countryCode: true, locale: true, walletAddress: true,
  lastSeenAt: true, createdAt: true, updatedAt: true,
};

export async function getProfile(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { ...USER_SELECT, region: true },
  });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);
  return user;
}

export async function updateProfile({ userId, displayName, phone, fcmToken, avatarUrl, logoUrl, slogan, languages, religion }) {
  return prisma.user.update({
    where: { id: userId },
    data: {
      ...(displayName && { displayName }),
      ...(phone && { phone }),
      ...(fcmToken && { fcmToken }),
      ...(avatarUrl && { avatarUrl }),
      ...(logoUrl && { logoUrl }),
      ...(slogan !== undefined && { slogan }),
      ...(languages?.length && { languages }),
      ...(religion !== undefined && { religion }),
    },
    select: USER_SELECT,
  });
}

export async function getDevices(userId) {
  return prisma.userDevice.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
}

export async function removeDevice({ userId, deviceId }) {
  const device = await prisma.userDevice.findUnique({ where: { id: deviceId } });
  if (!device || device.userId !== userId) {
    throw new AppError("Device not found", HttpStatus.NOT_FOUND, ErrorCodes.DEVICE_NOT_FOUND);
  }
  return prisma.userDevice.delete({ where: { id: deviceId } });
}

export async function getVotingHistory({ userId, page = 1, limit = 20 }) {
  const skip = (page - 1) * limit;
  const where = { voterId: userId };

  const [data, total] = await Promise.all([
    prisma.vote.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      include: { election: { select: { id: true, title: true, status: true, startDate: true, endDate: true } } },
      // Never expose candidateId — that's on-chain only
      select: { id: true, electionId: true, nullifierHash: true, createdAt: true, txHash: true, election: true },
    }),
    prisma.vote.count({ where }),
  ]);

  return { data, total, page, limit };
}

export async function getUserById(userId) {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { id: true, displayName: true, role: true, kycStatus: true, isBanned: true, createdAt: true } });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);
  return user;
}
