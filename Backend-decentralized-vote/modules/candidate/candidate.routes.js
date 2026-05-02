// ============================================================================
// VoteSecure — Candidate Routes
// ============================================================================

import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { register, listByElection, getById, updateProfile, handleApproval } from "./candidate.controller.js";
import { registerCandidateSchema, updateCandidateSchema, approveCandidateSchema } from "./candidate.validators.js";

const router = Router();

// Public
router.get("/election/:electionId", listByElection);
router.get("/:id", getById);

// Voter (register self as candidate)
router.post("/", authenticate, validate(registerCandidateSchema), register);
router.patch("/:id", authenticate, validate(updateCandidateSchema), updateProfile);

// Admin
router.post("/:id/review", authenticate, requireRole("ELECTION_ADMIN", "SUPER_ADMIN"), validate(approveCandidateSchema), handleApproval);

export default router;
