// ============================================================================
// VoteSecure — Election Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { requireRole } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import {
  list, getActive, getById, create, updatePhase, getResults, getByRegion,
} from "./election.controller.js";
import {
  createElectionSchema,
  updateElectionPhaseSchema,
} from "./election.validators.js";

const router = Router();

// Public
router.get("/", list);
router.get("/active", getActive);
router.get("/by-region/:regionId", getByRegion);
router.get("/:id", getById);
router.get("/:id/results", getResults);

// Admin only
router.post(
  "/",
  authenticate,
  requireRole("ELECTION_ADMIN", "SUPER_ADMIN"),
  validate(createElectionSchema),
  create
);
router.put(
  "/:id/phase",
  authenticate,
  requireRole("ELECTION_ADMIN", "SUPER_ADMIN"),
  validate(updateElectionPhaseSchema),
  updatePhase
);

export default router;
