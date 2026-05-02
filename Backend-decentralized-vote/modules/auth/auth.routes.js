// ============================================================================
// VoteSecure — Auth Routes
// ============================================================================

import { Router } from "express";
import { authenticate, verifyFirebaseToken } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import {
  register,
  signIn,
  signOut,
  getMe,
  verifyWallet,
  registerOnChain,
  bindDevice,
  deleteAccount,
} from "./auth.controller.js";
import {
  registerVoterSchema,
  verifyWalletSchema,
  biometricRegisterSchema,
} from "./auth.validators.js";

const router = Router();

// Public — needs Firebase token only (no DB user required yet)
router.post("/register", verifyFirebaseToken, validate(registerVoterSchema), register);
router.post("/signin", verifyFirebaseToken, signIn);

// Authenticated
router.post("/signout", authenticate, signOut);
router.get("/me", authenticate, getMe);
router.post("/verify-wallet", authenticate, validate(verifyWalletSchema), verifyWallet);
router.post("/register-on-chain", authenticate, registerOnChain);
router.post("/bind-device", authenticate, validate(biometricRegisterSchema), bindDevice);
router.delete("/account", authenticate, deleteAccount);

export default router;
