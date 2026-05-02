import { Router } from "express";
import { authenticate, requireRole } from "../../middlewares/auth.middleware.js";
import { users, setRole, ban, unban, overview, broadcast } from "./admin.controller.js";

const router = Router();
router.use(authenticate, requireRole("SUPER_ADMIN", "MODERATOR"));

router.get("/overview", requireRole("SUPER_ADMIN"), overview);
router.get("/users", users);
router.patch("/users/:userId/role", requireRole("SUPER_ADMIN"), setRole);
router.post("/users/:userId/ban", ban);
router.post("/users/:userId/unban", unban);
router.post("/broadcast", requireRole("SUPER_ADMIN"), broadcast);

export default router;
