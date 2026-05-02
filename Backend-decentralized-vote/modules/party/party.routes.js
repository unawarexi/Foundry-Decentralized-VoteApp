// ============================================================================
// VoteSecure — Party Routes
// ============================================================================

import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { create, list, getById, update, approve } from "./party.controller.js";
import { createPartySchema, updatePartySchema } from "./party.validators.js";

const router = Router();

router.get("/", list);
router.get("/:id", getById);
router.post("/", authenticate, validate(createPartySchema), create);
router.patch("/:id", authenticate, validate(updatePartySchema), update);
router.post("/:id/approve", authenticate, requireRole("ELECTION_ADMIN", "SUPER_ADMIN"), approve);

export default router;
