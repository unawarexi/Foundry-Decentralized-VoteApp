import * as notificationService from "./notification.service.js";
import { success, paginated } from "../../core/utils/api-response.js";
import { HttpStatus } from "../../config/constants.js";

export async function list(req, res, next) {
  try {
    const result = await notificationService.getNotifications({
      userId: req.user.id,
      page: req.query.page,
      limit: req.query.limit,
      unreadOnly: req.query.unreadOnly === "true",
    });
    paginated(res, result);
  } catch (err) { next(err); }
}

export async function markRead(req, res, next) {
  try {
    const result = await notificationService.markRead({
      userId: req.user.id,
      notificationId: req.params.id,
      markAll: req.query.all === "true",
    });
    success(res, result);
  } catch (err) { next(err); }
}

export async function remove(req, res, next) {
  try {
    await notificationService.deleteNotification({ userId: req.user.id, notificationId: req.params.id });
    res.status(HttpStatus.NO_CONTENT).send();
  } catch (err) { next(err); }
}
