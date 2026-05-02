// ============================================================================
// VoteSecure — Vote Routes
// ============================================================================

import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { castVote, hasVoted, getMyVotes } from "./vote.controller.js";
import { castVoteSchema } from "./vote.validators.js";

const router = Router();

router.use(authenticate);

router.post("/", validate(castVoteSchema), castVote);
router.get("/mine", getMyVotes);
router.get("/:electionId/status", hasVoted);

export default router;
