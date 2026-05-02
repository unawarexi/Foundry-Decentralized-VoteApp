import * as walletService from "./wallet.service.js";
import { success, paginated } from "../../core/utils/api-response.js";

export async function transactions(req, res, next) {
  try { paginated(res, await walletService.getTransactionHistory({ userId: req.user.id, ...req.query })); }
  catch (err) { next(err); }
}

export async function balance(req, res, next) {
  try { success(res, await walletService.getMyBalance(req.user.id)); }
  catch (err) { next(err); }
}
