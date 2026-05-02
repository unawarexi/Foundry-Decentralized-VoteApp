
// ============================================================================
// VOTESECURE — MAIN ENTRY POINT
// Decentralized Voting Platform Backend
// ============================================================================

import express from "express";
import http from "http";
import compression from "compression";

// Configuration
import { env, validateEnv } from "./config/env.config.js";
import { HttpStatus } from "./config/constants.js";
import { prisma, disconnectPrisma } from "./config/prisma.js";
import logger, { createLogger } from "./logs/logger.js";

// Observability
import { initializeSentry, setupSentryExpress } from "./logs/sentry.logs.js";
import { metricsMiddleware, metricsEndpoint } from "./logs/prometheus.logs.js";
import { healthCheckEndpoint, livenessProbe, readinessProbe } from "./logs/grafana.logs.js";

// Middleware
import {
  securityHeaders,
  corsConfig,
  configureTrustProxy,
  xssProtection,
} from "./middlewares/security.middleware.js";
import { requestId, requestLogger } from "./middlewares/request-logger.middleware.js";
import { globalErrorHandler } from "./middlewares/errorhandler.middleware.js";
import { apiLimiter } from "./middlewares/ratelimit.middleware.js";

// Services
import { initRedis, disconnectRedis } from "./services/redis.service.js";
import { initKafka, disconnectKafka } from "./services/kafka.service.js";
import { initQueues, disconnectBullMQ } from "./services/bullmq.service.js";
import { initWebSocket, disconnectWebSocket } from "./services/websocket.service.js";
import { verifyMailer } from "./services/mailer.service.js";
import { initBlockchain } from "./services/blockchain/blockchain.service.js";
import { initPaymentService } from "./services/payment/payment.service.js";
import { startWorkers } from "./services/workers.js";
import { initAIConsumer, disconnectAIConsumer } from "./services/ai-consumer.service.js";

// Module routes
import authRoutes from "./modules/auth/auth.routes.js";
import userRoutes from "./modules/user/user.routes.js";
import electionRoutes from "./modules/election/election.routes.js";
import voteRoutes from "./modules/vote/vote.routes.js";
import candidateRoutes from "./modules/candidate/candidate.routes.js";
import partyRoutes from "./modules/party/party.routes.js";
import regionRoutes from "./modules/region/region.routes.js";
import forumRoutes from "./modules/forum/forum.routes.js";
import fraudRoutes from "./modules/fraud/fraud.routes.js";
import notificationRoutes from "./modules/notification/notification.routes.js";
import analyticsRoutes from "./modules/analytics/analytics.routes.js";
import adminRoutes from "./modules/admin/admin.routes.js";
import walletRoutes from "./modules/wallet/wallet.routes.js";

const log = createLogger("Server");

// ============================================================================
// EXPRESS APPLICATION SETUP
// ============================================================================

const app = express();
const server = http.createServer(app);

// ============================================================================
// PRE-ROUTE MIDDLEWARE
// ============================================================================

// Trust proxy (nginx / load balancer)
configureTrustProxy(app);

// Sentry must be initialized before other middleware
initializeSentry();

// Security
app.use(securityHeaders());
app.use(corsConfig());
app.use(xssProtection);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Compression
app.use(compression());

// Request tracking
app.use(requestId);

// Prometheus metrics collection
app.use(metricsMiddleware);

// Request logging (skip in tests)
if (env.NODE_ENV !== "test") {
  app.use(requestLogger);
}

// Global rate limiter
app.use(apiLimiter);

// ============================================================================
// HEALTH & OBSERVABILITY ENDPOINTS
// ============================================================================

app.get("/health", livenessProbe);
app.get("/health/ready", readinessProbe);
app.get("/health/detailed", healthCheckEndpoint);
app.get("/metrics", metricsEndpoint);

// ============================================================================
// API ROUTES (v1)
// ============================================================================

const API = "/api/v1";

app.use(`${API}/auth`, authRoutes);
app.use(`${API}/users`, userRoutes);
app.use(`${API}/elections`, electionRoutes);
app.use(`${API}/votes`, voteRoutes);
app.use(`${API}/candidates`, candidateRoutes);
app.use(`${API}/parties`, partyRoutes);
app.use(`${API}/regions`, regionRoutes);
app.use(`${API}/forum`, forumRoutes);
app.use(`${API}/fraud`, fraudRoutes);
app.use(`${API}/notifications`, notificationRoutes);
app.use(`${API}/analytics`, analyticsRoutes);
app.use(`${API}/admin`, adminRoutes);
app.use(`${API}/wallet`, walletRoutes);

// API info
app.get(API, (_req, res) => {
  res.status(HttpStatus.OK).json({
    name: "VoteSecure API",
    version: "1.0.0",
    description: "Decentralized Voting Platform API",
    endpoints: {
      auth: `${API}/auth`,
      users: `${API}/users`,
      elections: `${API}/elections`,
      votes: `${API}/votes`,
      candidates: `${API}/candidates`,
      parties: `${API}/parties`,
      regions: `${API}/regions`,
      forum: `${API}/forum`,
      fraud: `${API}/fraud`,
      notifications: `${API}/notifications`,
      analytics: `${API}/analytics`,
      admin: `${API}/admin`,
      wallet: `${API}/wallet`,
    },
    health: "/health",
    metrics: "/metrics",
  });
});

// ============================================================================
// SENTRY ERROR HANDLER (must be after routes, before custom error handler)
// ============================================================================

setupSentryExpress(app);

// ============================================================================
// 404 + GLOBAL ERROR HANDLER
// ============================================================================

app.use((_req, res) => {
  res.status(HttpStatus.NOT_FOUND).json({
    success: false,
    message: `Route not found`,
  });
});

app.use(globalErrorHandler);

// ============================================================================
// SERVER STARTUP
// ============================================================================

async function startServer() {
  try {
    validateEnv();

    // Verify database connection
    await prisma.$queryRaw`SELECT 1`;
    log.info("PostgreSQL connected");

    // Connect services
    await initRedis();
    log.info("Redis connected");

    if (env.KAFKA_BROKERS) {
      await initKafka();
      log.info("Kafka connected");
    }

    // Initialize queues & workers
    initQueues();
    startWorkers();
    log.info("BullMQ queues & workers initialized");

    // Initialize WebSocket with Socket.IO
    initWebSocket(server);
    log.info("WebSocket initialized");

    // Start AI Kafka consumer
    if (env.KAFKA_BROKERS) {
      await initAIConsumer();
      log.info("AI Kafka consumer initialized");
    }

    // Initialize blockchain + payment
    await initBlockchain();
    log.info("Blockchain service initialized");

    await initPaymentService();
    log.info("Payment service initialized");

    // Verify SMTP (non-blocking)
    verifyMailer().catch((err) => log.warn("SMTP verification failed", { error: err }));

    // Start HTTP server
    const PORT = env.PORT || 5000;

    server.listen(PORT, () => {
      log.info("=".repeat(56));
      log.info("  VOTESECURE BACKEND SERVER");
      log.info("=".repeat(56));
      log.info(`  Environment : ${env.NODE_ENV}`);
      log.info(`  Port        : ${PORT}`);
      log.info(`  API         : /api/v1`);
      log.info(`  Health      : http://localhost:${PORT}/health`);
      log.info(`  Metrics     : http://localhost:${PORT}/metrics`);
      log.info("=".repeat(56));
    });
  } catch (error) {
    log.error("Failed to start server", { error });
    process.exit(1);
  }
}

// ============================================================================
// GRACEFUL SHUTDOWN
// ============================================================================

async function gracefulShutdown(signal) {
  log.info(`${signal} received — shutting down...`);

  server.close(() => log.info("HTTP server closed"));

  try { await disconnectPrisma(); log.info("Database disconnected"); } catch {}
  try { await disconnectRedis(); log.info("Redis disconnected"); } catch {}
  try { await disconnectAIConsumer(); log.info("AI consumer disconnected"); } catch {}
  try { await disconnectKafka(); log.info("Kafka disconnected"); } catch {}
  try { await disconnectBullMQ(); log.info("BullMQ disconnected"); } catch {}
  try { await disconnectWebSocket(); log.info("WebSocket disconnected"); } catch {}

  log.info("Graceful shutdown completed");
  process.exit(0);
}

process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));
process.on("SIGINT", () => gracefulShutdown("SIGINT"));

process.on("uncaughtException", (error) => {
  console.error("Uncaught Exception:", error);
  gracefulShutdown("uncaughtException");
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
});

// ============================================================================
// START
// ============================================================================

startServer();

export { app, server };
