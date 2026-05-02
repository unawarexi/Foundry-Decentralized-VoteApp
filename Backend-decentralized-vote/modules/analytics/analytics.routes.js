import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { electionAnalytics, platformStats, turnoutByRegion } from "./analytics.controller.js";

const router = Router();

router.get("/platform", authenticate, requireRole("ELECTION_ADMIN", "SUPER_ADMIN"), platformStats);
router.get("/election/:electionId", electionAnalytics);
router.get("/election/:electionId/turnout-by-region", authenticate, requireRole("ELECTION_ADMIN", "SUPER_ADMIN"), turnoutByRegion);

export default router;
