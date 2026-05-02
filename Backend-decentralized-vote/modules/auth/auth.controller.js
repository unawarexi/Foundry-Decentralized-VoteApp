// ============================================================================
// VoteSecure — Auth Controller
// ============================================================================

import * as authService from "./auth.service.js";
import { success, created } from "../../core/utils/api-response.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";

const log = createLogger("AuthController");

// POST /api/v1/auth/register
export async function register(req, res, next) {
  try {
    const { email, displayName, phone, walletAddress, regionId, locale, fcmToken } = req.body;
    const { uid } = req.firebaseUser;

    const user = await authService.registerVoter({
      firebaseUid: uid,
      email: email || req.firebaseUser.email,
      displayName,
      phone,
      walletAddress,
      regionId,
      locale,
      fcmToken,
    });

    created(res, user, "Voter registered successfully");
  } catch (err) {
    next(err);
  }
}

// POST /api/v1/auth/signin
export async function signIn(req, res, next) {
  try {
    const { uid, email, name, picture } = req.firebaseUser;

    const user = await authService.syncUserFromFirebase({
      uid,
      email,
      displayName: name,
      photoURL: picture,
    });

    if (user.isBanned) {
      return next(
        new AppError("Account is banned", HttpStatus.FORBIDDEN, ErrorCodes.VOTER_BANNED)
      );
    }

    if (!user.isActive) {
      return next(
        new AppError("Account is deactivated", HttpStatus.FORBIDDEN, ErrorCodes.ACCOUNT_DEACTIVATED)
      );
    }

    success(res, user, "Signed in successfully");
  } catch (err) {
    next(err);
  }
}

// POST /api/v1/auth/signout
export async function signOut(req, res, next) {
  try {
    // Firebase signout is client-side; we just acknowledge
    success(res, null, "Signed out successfully");
  } catch (err) {
    next(err);
  }
}

// GET /api/v1/auth/me
export async function getMe(req, res, next) {
  try {
    const user = await authService.getUserById(req.user.id);
    success(res, user);
  } catch (err) {
    next(err);
  }
}

// POST /api/v1/auth/verify-wallet
export async function verifyWallet(req, res, next) {
  try {
    const { walletAddress, signature, message } = req.body;
    const updated = await authService.verifyAndLinkWallet({
      userId: req.user.id,
      walletAddress,
      signature,
      message,
    });
    success(res, { walletAddress: updated.walletAddress }, "Wallet verified and linked");
  } catch (err) {
    next(err);
  }
}

// POST /api/v1/auth/register-on-chain
export async function registerOnChain(req, res, next) {
  try {
    const result = await authService.registerVoterOnBlockchain({ userId: req.user.id });
    success(res, result, "Voter registered on blockchain");
  } catch (err) {
    next(err);
  }
}

// POST /api/v1/auth/bind-device
export async function bindDevice(req, res, next) {
  try {
    const { deviceId, deviceType, deviceModel, osVersion, appVersion, fcmToken } = req.body;
    const device = await authService.bindDevice({
      userId: req.user.id,
      deviceId,
      deviceType,
      deviceModel,
      osVersion,
      appVersion,
      fcmToken,
    });
    success(res, device, "Device bound successfully");
  } catch (err) {
    next(err);
  }
}

// DELETE /api/v1/auth/account
export async function deleteAccount(req, res, next) {
  try {
    await authService.deleteAccount({ userId: req.user.id });
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) {
    next(err);
  }
}
