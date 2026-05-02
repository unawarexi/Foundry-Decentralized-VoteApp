// ============================================================================
// VoteSecure — Auth Validators (Zod)
// ============================================================================

import { z } from "zod";

export const registerVoterSchema = z.object({
  email: z.string().email("Invalid email address"),
  displayName: z.string().min(2).max(100),
  phone: z.string().regex(/^\+?[1-9]\d{7,14}$/, "Invalid phone number").optional(),
  walletAddress: z
    .string()
    .regex(/^0x[a-fA-F0-9]{40}$/, "Invalid Ethereum wallet address")
    .optional(),
  regionId: z.string().uuid("Invalid region ID").optional(),
  locale: z.string().length(2).default("en").optional(),
  fcmToken: z.string().optional(),
});

export const verifyWalletSchema = z.object({
  walletAddress: z.string().regex(/^0x[a-fA-F0-9]{40}$/, "Invalid Ethereum wallet address"),
  signature: z.string().min(1, "Signature required"),
  message: z.string().min(1, "Signed message required"),
});

export const biometricRegisterSchema = z.object({
  deviceId: z.string().min(10, "Device ID required"),
  deviceType: z.enum(["android", "ios", "web", "kiosk"]),
  deviceModel: z.string().optional(),
  osVersion: z.string().optional(),
  appVersion: z.string().optional(),
  fcmToken: z.string().optional(),
});

export const updateProfileSchema = z.object({
  displayName: z.string().min(2).max(100).optional(),
  phone: z.string().regex(/^\+?[1-9]\d{7,14}$/).optional(),
  avatarUrl: z.string().url().optional(),
  fcmToken: z.string().optional(),
  locale: z.string().length(2).optional(),
});
