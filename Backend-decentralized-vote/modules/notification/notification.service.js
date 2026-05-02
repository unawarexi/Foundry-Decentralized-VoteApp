// ============================================================================
// VoteSecure — Notification Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import admin from "../../config/firebase-admin.config.js";

const log = createLogger("NotificationService");

export async function sendNotification({ userId, type, title, body, data = {} }) {
  // Store in DB
  const notification = await prisma.notification.create({
    data: { userId, type, title, body, data },
  });

  // Push via FCM
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { fcmToken: true } });
  if (user?.fcmToken) {
    try {
      await admin.messaging().send({
        token: user.fcmToken,
        notification: { title, body },
        data: { notificationId: notification.id, type, ...data },
      });
      await prisma.notification.update({ where: { id: notification.id }, data: { sentAt: new Date() } });
    } catch (err) {
      log.warn(`FCM push failed for user ${userId}`, { error: err.message });
    }
  }

  return notification;
}

export async function broadcastNotification({ userIds, type, title, body, data = {} }) {
  return Promise.allSettled(userIds.map((userId) => sendNotification({ userId, type, title, body, data })));
}

export async function getNotifications({ userId, page = 1, limit = 20, unreadOnly = false }) {
  const skip = (page - 1) * limit;
  const where = { userId };
  if (unreadOnly) where.isRead = false;

  const [data, total, unreadCount] = await Promise.all([
    prisma.notification.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
    }),
    prisma.notification.count({ where }),
    prisma.notification.count({ where: { userId, isRead: false } }),
  ]);

  return { data, total, page, limit, unreadCount };
}

export async function markRead({ userId, notificationId, markAll = false }) {
  if (markAll) {
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true, readAt: new Date() },
    });
    return { markedAll: true };
  }

  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification || notification.userId !== userId) {
    throw new AppError("Notification not found", HttpStatus.NOT_FOUND, ErrorCodes.NOTIFICATION_NOT_FOUND);
  }

  return prisma.notification.update({
    where: { id: notificationId },
    data: { isRead: true, readAt: new Date() },
  });
}

export async function deleteNotification({ userId, notificationId }) {
  const notification = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!notification || notification.userId !== userId) {
    throw new AppError("Notification not found", HttpStatus.NOT_FOUND, ErrorCodes.NOTIFICATION_NOT_FOUND);
  }
  return prisma.notification.delete({ where: { id: notificationId } });
}
