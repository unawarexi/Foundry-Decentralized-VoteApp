import { Router } from "express";
import { authenticate } from "../../middlewares/auth.middleware.js";
import { transactions, balance } from "./wallet.controller.js";

const router = Router();
router.use(authenticate);

router.get("/transactions", transactions);
router.get("/balance", balance);

export default router;
