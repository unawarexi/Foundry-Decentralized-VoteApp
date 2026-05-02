// ============================================================================
// VoteSecure — Region Routes
// ============================================================================

import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { list, getById, create, update, assignVoter, getElections } from "./region.controller.js";
import { createRegionSchema, updateRegionSchema, assignVoterSchema } from "./region.validators.js";

const router = Router();

router.get("/", list);
router.get("/:id", getById);
router.get("/:id/elections", getElections);

router.post("/", authenticate, requireRole("REGION_ADMIN", "SUPER_ADMIN"), validate(createRegionSchema), create);
router.patch("/:id", authenticate, requireRole("REGION_ADMIN", "SUPER_ADMIN"), validate(updateRegionSchema), update);
router.post("/:id/assign-voter", authenticate, requireRole("REGION_ADMIN", "SUPER_ADMIN"), validate(assignVoterSchema), assignVoter);

export default router;
