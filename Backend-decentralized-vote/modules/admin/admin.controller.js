import * as adminService from "./admin.service.js";
import { success, paginated } from "../../core/utils/api-response.js";

export async function users(req, res, next) {
  try { paginated(res, await adminService.listUsers(req.query)); }
  catch (err) { next(err); }
}

export async function setRole(req, res, next) {
  try { success(res, await adminService.setUserRole({ adminId: req.user.id, userId: req.params.userId, ...req.body })); }
  catch (err) { next(err); }
}

export async function ban(req, res, next) {
  try { success(res, await adminService.banUser({ adminId: req.user.id, userId: req.params.userId, ...req.body })); }
  catch (err) { next(err); }
}

export async function unban(req, res, next) {
  try { success(res, await adminService.unbanUser({ adminId: req.user.id, userId: req.params.userId })); }
  catch (err) { next(err); }
}

export async function overview(req, res, next) {
  try { success(res, await adminService.getPlatformOverview()); }
  catch (err) { next(err); }
}

export async function broadcast(req, res, next) {
  try { success(res, await adminService.broadcastSystemNotification({ adminId: req.user.id, ...req.body })); }
  catch (err) { next(err); }
}
