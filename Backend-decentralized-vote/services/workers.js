// ============================================================================
// VoteSecure — BullMQ Workers
// Email, notification, SLA-check, and analytics cache-refresh job processors
// ============================================================================

import { registerWorker, initQueues } from "../services/bullmq.service.js";
import { sendEmail } from "../services/email/email.service.js";
import { createLogger } from "../logs/logger.js";

const log = createLogger("Workers");

// ============================================================================
// EMAIL WORKER
// ============================================================================

async function processEmailJob(job) {
  const { type, to, subject, html, text } = job.data;
  await sendEmail({ to, subject, html, text });
  log.info("Email sent via worker", { type, to, jobId: job.id });
}

// ============================================================================
// NOTIFICATION WORKER
// ============================================================================

async function processNotificationJob(job) {
  const { type, userId, title, body, data } = job.data;
  const { sendNotification } = await import("../modules/notification/notification.service.js");
  await sendNotification({ userId, type, title, body, data: data || {} });
  log.info("Notification processed", { type, userId, jobId: job.id });
}

// ============================================================================
// SLA CHECKER WORKER
// ============================================================================

async function processSLACheckJob() {
  const { checkSLABreaches } = await import("../modules/forum/forum.service.js");
  await checkSLABreaches();
  log.info("SLA breach check completed");
}

// ============================================================================
// REGISTER ALL WORKERS
// ============================================================================

export function startWorkers() {
  initQueues();

  registerWorker("EMAIL", processEmailJob, { concurrency: 10 });
  registerWorker("NOTIFICATION", processNotificationJob, { concurrency: 10 });
  registerWorker("SLA_CHECK", processSLACheckJob, { concurrency: 1 });

  log.info("All workers started");
}

// ============================================================================
// HELPER — Queue an email job
// ============================================================================

export async function queueEmail(type, to, subject, html, options = {}) {
  const { addJob } = await import("../services/bullmq.service.js");
  return addJob("EMAIL", `email:${type}`, { type, to, subject, html }, {
    priority: options.priority || 3,
    delay: options.delay || 0,
    ...options,
  });
}

// ============================================================================
// HELPER — Queue a notification job
// ============================================================================

export async function queueNotification(userId, type, title, body, data = {}, options = {}) {
  const { addJob } = await import("../services/bullmq.service.js");
  return addJob("NOTIFICATION", `notification:${type}`, { userId, type, title, body, data }, {
    priority: options.priority || 2,
    ...options,
  });
}

export default { startWorkers, queueEmail, queueNotification };
