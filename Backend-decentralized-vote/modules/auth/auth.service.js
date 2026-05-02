// ============================================================================
// VoteSecure — Auth Service
// Firebase auth + PostgreSQL sync + wallet binding + voter registration
// ============================================================================

import { ethers } from "ethers";
import admin from "../../config/firebase-admin.config.js";
import { prisma } from "../../config/prisma.js";
import { createLogger } from "../../logs/logger.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import {
  registerVoterOnChain,
  isVoterRegistered,
} from "../../services/blockchain/blockchain.service.js";
import { aiRequest } from "../../services/ai-gateway.service.js";
import { getRedisClient as getRedis } from "../../services/redis.service.js";
import { CacheTTL } from "../../config/constants.js";

const log = createLogger("AuthService");

// ============================================================================
// USER SYNC — create or update user from Firebase token
// ============================================================================

export async function syncUserFromFirebase({ uid, email, displayName, photoURL }) {
  const user = await prisma.user.upsert({
    where: { firebaseUid: uid },
    update: {
      email,
      displayName: displayName || undefined,
      avatarUrl: photoURL || undefined,
      lastSeenAt: new Date(),
      emailVerified: true,
    },
    create: {
      firebaseUid: uid,
      email,
      displayName: displayName || email.split("@")[0],
      avatarUrl: photoURL || undefined,
      emailVerified: true,
      lastSeenAt: new Date(),
    },
    include: { region: true },
  });

  return user;
}

// ============================================================================
// REGISTER VOTER
// Full flow: validate → sync to DB → optionally register on-chain
// ============================================================================

export async function registerVoter({ firebaseUid, email, displayName, phone, walletAddress, regionId, locale, fcmToken, avatarUrl, logoUrl, slogan, languages, religion }) {
  // Ensure user exists in DB
  let user = await prisma.user.findUnique({ where: { firebaseUid } });
  if (!user) {
    user = await prisma.user.create({
      data: {
        firebaseUid,
        email,
        displayName: displayName || email.split("@")[0],
        phone,
        walletAddress,
        regionId,
        locale: locale || "en",
        fcmToken,
        emailVerified: true,
        avatarUrl,
        logoUrl,
        slogan,
        languages: languages || [],
        religion,
      },
    });
  } else {
    // Update with any new data
    user = await prisma.user.update({
      where: { id: user.id },
      data: {
        phone: phone || user.phone,
        walletAddress: walletAddress || user.walletAddress,
        regionId: regionId || user.regionId,
        fcmToken: fcmToken || user.fcmToken,
        displayName: displayName || user.displayName,
        ...(avatarUrl && { avatarUrl }),
        ...(logoUrl && { logoUrl }),
        ...(slogan && { slogan }),
        ...(languages?.length && { languages }),
        ...(religion && { religion }),
        updatedAt: new Date(),
      },
    });
  }

  log.info(`Voter registered/synced: ${user.id}`);
  return user;
}

// ============================================================================
// WALLET VERIFY
// Validate EIP-191 signature to prove wallet ownership, then link to account
// ============================================================================

export async function verifyAndLinkWallet({ userId, walletAddress, signature, message }) {
  // Recover signer from signature
  let recoveredAddress;
  try {
    recoveredAddress = ethers.verifyMessage(message, signature);
  } catch {
    throw new AppError("Invalid signature", HttpStatus.BAD_REQUEST, ErrorCodes.INVALID_SIGNATURE);
  }

  if (recoveredAddress.toLowerCase() !== walletAddress.toLowerCase()) {
    throw new AppError(
      "Signature does not match wallet address",
      HttpStatus.BAD_REQUEST,
      ErrorCodes.INVALID_SIGNATURE
    );
  }

  // Check wallet not already linked to another account
  const existingUser = await prisma.user.findUnique({ where: { walletAddress } });
  if (existingUser && existingUser.id !== userId) {
    throw new AppError(
      "This wallet is already linked to another account",
      HttpStatus.CONFLICT,
      ErrorCodes.WALLET_ALREADY_LINKED
    );
  }

  const updated = await prisma.user.update({
    where: { id: userId },
    data: { walletAddress },
  });

  log.info(`Wallet linked: ${walletAddress} → user ${userId}`);
  return updated;
}

// ============================================================================
// REGISTER VOTER ON-CHAIN
// Called when user reaches BIOMETRIC_VERIFIED KYC level
// ============================================================================

export async function registerVoterOnBlockchain({ userId }) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { region: true },
  });

  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);
  if (!user.walletAddress) {
    throw new AppError("Wallet address required before on-chain registration", HttpStatus.BAD_REQUEST, ErrorCodes.WALLET_NOT_CONNECTED);
  }
  if (!user.regionId) {
    throw new AppError("Region must be assigned before on-chain registration", HttpStatus.BAD_REQUEST, ErrorCodes.REGION_NOT_FOUND);
  }

  // Check if already registered
  try {
    const alreadyRegistered = await isVoterRegistered(user.walletAddress);
    if (alreadyRegistered) {
      log.info(`Voter ${userId} already registered on-chain`);
      return { alreadyRegistered: true };
    }
  } catch {
    log.warn("Could not check on-chain registration status — continuing");
  }

  // Compute identity hash (keccak256 of userId + regionId + verified)
  const identityHash = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(
      ["string", "string", "bool"],
      [userId, user.regionId, true]
    )
  );

  // Store identity hash off-chain
  await prisma.user.update({
    where: { id: userId },
    data: { identityHash },
  });

  // Register on-chain
  const receipt = await registerVoterOnChain({
    walletAddress: user.walletAddress,
    identityHash,
    regionId: user.regionId,
  });

  log.info(`Voter registered on-chain: ${user.walletAddress} (tx: ${receipt.hash})`);
  return { txHash: receipt.hash, identityHash };
}

// ============================================================================
// BIND DEVICE
// ============================================================================

export async function bindDevice({ userId, deviceId, deviceType, deviceModel, osVersion, appVersion, fcmToken }) {
  const device = await prisma.userDevice.upsert({
    where: { deviceId },
    update: {
      deviceType,
      deviceModel,
      osVersion,
      appVersion,
      fcmToken,
      lastActiveAt: new Date(),
    },
    create: {
      userId,
      deviceId,
      deviceType,
      deviceModel,
      osVersion,
      appVersion,
      fcmToken,
      isTrusted: false,
    },
  });

  // Update user's primary device and FCM token
  if (fcmToken) {
    await prisma.user.update({
      where: { id: userId },
      data: { deviceId, fcmToken },
    });
  }

  log.info(`Device bound: ${deviceId} → user ${userId}`);
  return device;
}

// ============================================================================
// SOFT DELETE ACCOUNT
// ============================================================================

export async function deleteAccount({ userId }) {
  await prisma.user.update({
    where: { id: userId },
    data: {
      isActive: false,
      email: `deleted-${Date.now()}@deleted.invalid`,
      phone: null,
      walletAddress: null,
      fcmToken: null,
      displayName: "Deleted Account",
    },
  });

  // Revoke Firebase user
  try {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (user?.firebaseUid) {
      await admin.auth().revokeRefreshTokens(user.firebaseUid);
    }
  } catch (err) {
    log.warn("Could not revoke Firebase tokens", { error: err.message });
  }

  // Invalidate cache
  const redis = getRedis();
  if (redis) await redis.del(`user:${userId}`);

  log.info(`Account deleted: ${userId}`);
}

// ============================================================================
// GET CURRENT USER (with cache)
// ============================================================================

export async function getUserById(userId) {
  const redis = getRedis();
  const cacheKey = `user:${userId}`;

  if (redis) {
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      region: true,
      candidateProfile: true,
      devices: true,
    },
  });

  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);

  if (redis) {
    await redis.setex(cacheKey, CacheTTL.USER_PROFILE, JSON.stringify(user));
  }

  return user;
}
