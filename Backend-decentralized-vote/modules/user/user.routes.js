import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { me, updateMe, devices, removeDevice, votingHistory, getUser } from "./user.controller.js";

const router = Router();

router.get("/me", authenticate, me);
router.patch("/me", authenticate, updateMe);
router.get("/me/devices", authenticate, devices);
router.delete("/me/devices/:deviceId", authenticate, removeDevice);
router.get("/me/votes", authenticate, votingHistory);
router.get("/:userId", getUser);

export default router;
