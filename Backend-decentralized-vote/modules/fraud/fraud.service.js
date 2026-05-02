// ============================================================================
// VoteSecure — Fraud Service
// AI-assisted fraud detection + on-chain flagging
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes, FraudConfig } from "../../config/constants.js";
import { createLogger } from "../../logs/logger.js";
import {
  submitFraudFlagOnChain,
  banVoterOnChain,
  getVoterRiskScore,
} from "../../services/blockchain/blockchain.service.js";
import { aiRequest } from "../../services/ai-gateway.service.js";

const log = createLogger("FraudService");

export async function reportFraud({ reporterId, flaggedUserId, electionId, description, evidenceHash }) {
  // Prevent self-reporting
  if (reporterId === flaggedUserId) {
    throw new AppError("Cannot report yourself", HttpStatus.BAD_REQUEST, ErrorCodes.VALIDATION_ERROR);
  }

  // Check not already reported recently (same reporter, same user, within 24h)
  const recentReport = await prisma.fraudReport.findFirst({
    where: {
      reporterId,
      flaggedUserId,
      createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
    },
  });
  if (recentReport) {
    throw new AppError("You have already reported this user recently", HttpStatus.CONFLICT, ErrorCodes.FRAUD_ALREADY_REPORTED);
  }

  // Get AI risk score
  let aiRiskScore = null;
  let severity = "LOW";
  try {
    const aiResult = await aiRequest("POST", "/fraud/analyze", {
      reporterId,
      flaggedUserId,
      electionId,
      description,
    });
    aiRiskScore = aiResult?.riskScore;
    if (aiRiskScore >= FraudConfig.AI_RISK_THRESHOLD_CRITICAL) severity = "CRITICAL";
    else if (aiRiskScore >= FraudConfig.AI_RISK_THRESHOLD_HIGH) severity = "HIGH";
    else if (aiRiskScore >= FraudConfig.AI_RISK_THRESHOLD_MEDIUM) severity = "MEDIUM";
  } catch (err) {
    log.warn("AI fraud analysis unavailable", { error: err.message });
  }

  const report = await prisma.fraudReport.create({
    data: {
      reporterId,
      flaggedUserId,
      electionId,
      description,
      evidenceHash,
      severity,
      aiRiskScore,
      status: "PENDING",
    },
  });

  // Auto-ban if AI score is critical
  if (aiRiskScore >= FraudConfig.AUTO_BAN_THRESHOLD) {
    await autoBanUser({ userId: flaggedUserId, reason: `Auto-banned: AI risk score ${aiRiskScore}` });
  }

  // Submit to blockchain if high severity
  if (["HIGH", "CRITICAL"].includes(severity) && evidenceHash) {
    const flaggedUser = await prisma.user.findUnique({ where: { id: flaggedUserId } });
    if (flaggedUser?.walletAddress) {
      submitFraudFlagOnChain({
        walletAddress: flaggedUser.walletAddress,
        evidenceHash: `0x${Buffer.from(evidenceHash).toString("hex").padStart(64, "0").slice(0, 64)}`,
        severity,
      }).catch((err) => log.warn("On-chain fraud flag failed", { error: err.message }));
    }
  }

  log.info(`Fraud reported: ${flaggedUserId} by ${reporterId} (severity: ${severity})`);
  return report;
}

export async function resolveReport({ adminId, reportId, confirmed, resolution }) {
  const report = await prisma.fraudReport.findUnique({ where: { id: reportId } });
  if (!report) throw new AppError("Report not found", HttpStatus.NOT_FOUND, ErrorCodes.FRAUD_REPORT_NOT_FOUND);

  const updated = await prisma.fraudReport.update({
    where: { id: reportId },
    data: {
      status: confirmed ? "CONFIRMED" : "DISMISSED",
      resolvedBy: adminId,
      resolvedAt: new Date(),
      resolution,
    },
  });

  if (confirmed) {
    await autoBanUser({ userId: report.flaggedUserId, reason: `Fraud confirmed: ${resolution}` });
  }

  return updated;
}

export async function autoBanUser({ userId, reason }) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) return;

  await prisma.user.update({
    where: { id: userId },
    data: { isBanned: true, banReason: reason, bannedAt: new Date() },
  });

  // Ban on-chain
  if (user.walletAddress) {
    banVoterOnChain({ walletAddress: user.walletAddress, reason })
      .catch((err) => log.warn("On-chain ban failed", { error: err.message }));
  }

  log.info(`User banned: ${userId} — ${reason}`);
}

export async function listReports({ status, severity, page = 1, limit = 20 }) {
  const skip = (page - 1) * limit;
  const where = {};
  if (status) where.status = status;
  if (severity) where.severity = severity;

  const [data, total] = await Promise.all([
    prisma.fraudReport.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      include: {
        reporter: { select: { id: true, displayName: true } },
        flaggedUser: { select: { id: true, displayName: true, walletAddress: true } },
      },
    }),
    prisma.fraudReport.count({ where }),
  ]);

  return { data, total, page, limit };
}

export async function getUserRiskScore(userId) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new AppError("User not found", HttpStatus.NOT_FOUND, ErrorCodes.USER_NOT_FOUND);

  let onChainScore = null;
  if (user.walletAddress) {
    try {
      onChainScore = await getVoterRiskScore(user.walletAddress);
    } catch {
      // non-fatal
    }
  }

  const reportCount = await prisma.fraudReport.count({ where: { flaggedUserId: userId } });

  return { userId, walletAddress: user.walletAddress, onChainRiskScore: onChainScore, reportCount, isBanned: user.isBanned };
}
