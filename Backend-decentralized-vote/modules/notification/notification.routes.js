import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { list, markRead, remove } from "./notification.controller.js";

const router = Router();
router.use(authenticate);

router.get("/", list);
router.patch("/:id/read", markRead);
router.delete("/:id", remove);

export default router;
