import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { validate } from "../../middlewares/validate.middleware.js";
import { report, list, resolve, getRiskScore } from "./fraud.controller.js";
import { reportFraudSchema, resolveReportSchema } from "./fraud.validators.js";

const router = Router();

router.post("/", authenticate, validate(reportFraudSchema), report);
router.get("/", authenticate, requireRole("FRAUD_ORACLE", "SUPER_ADMIN", "MODERATOR"), list);
router.post("/:id/resolve", authenticate, requireRole("FRAUD_ORACLE", "SUPER_ADMIN"), validate(resolveReportSchema), resolve);
router.get("/risk/:userId", authenticate, requireRole("FRAUD_ORACLE", "SUPER_ADMIN"), getRiskScore);

export default router;
