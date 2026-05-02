// ============================================================================
// VoteSecure — Environment Configuration
// ============================================================================

import dotenv from "dotenv";
import path from "path";

dotenv.config({ path: path.resolve(process.cwd(), ".env") });

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

function getEnvString(key, defaultValue) {
  const value = process.env[key];
  if (value === undefined) {
    if (defaultValue !== undefined) return defaultValue;
    console.warn(`[Config] Missing environment variable: ${key}`);
    return "";
  }
  return value;
}

function getEnvNumber(key, defaultValue) {
  const value = process.env[key];
  if (value === undefined) {
    if (defaultValue !== undefined) return defaultValue;
    console.warn(`[Config] Missing environment variable: ${key}`);
    return 0;
  }
  const parsed = parseInt(value, 10);
  if (isNaN(parsed)) {
    console.warn(`[Config] Environment variable ${key} must be a number, got: ${value}`);
    return defaultValue || 0;
  }
  return parsed;
}

function getEnvBoolean(key, defaultValue = false) {
  const value = process.env[key];
  if (value === undefined) return defaultValue;
  return value === "true" || value === "1";
}

// ============================================================================
// CONFIGURATION OBJECT
// ============================================================================

export const env = {
  // --------------------------------------------------------------------------
  // App
  // --------------------------------------------------------------------------
  NODE_ENV: getEnvString("NODE_ENV", "development"),
  PORT: getEnvNumber("PORT", 3000),
  HOST: getEnvString("HOST", "0.0.0.0"),
  BASE_URL: getEnvString("BASE_URL", "http://localhost:3000"),

  // --------------------------------------------------------------------------
  // Security
  // --------------------------------------------------------------------------
  FRONTEND_URL: getEnvString("FRONTEND_URL", ""),
  CORS_ORIGINS: process.env.CORS_ORIGINS
    ? process.env.CORS_ORIGINS.split(",").map((s) => s.trim())
    : [],
  TRUST_PROXY: process.env.TRUST_PROXY === "true" || process.env.NODE_ENV === "production",
  DISABLE_HELMET: process.env.DISABLE_HELMET === "true",

  // --------------------------------------------------------------------------
  // Database (PostgreSQL via Prisma)
  // --------------------------------------------------------------------------
  DATABASE_URL: getEnvString("DATABASE_URL", ""),

  // --------------------------------------------------------------------------
  // Firebase Admin SDK
  // --------------------------------------------------------------------------
  FIREBASE_SERVICE_ACCOUNT: getEnvString("FIREBASE_SERVICE_ACCOUNT", ""),

  // --------------------------------------------------------------------------
  // LiveKit (WebRTC SFU)
  // --------------------------------------------------------------------------
  LIVEKIT_API_KEY: getEnvString("LIVEKIT_API_KEY", ""),
  LIVEKIT_API_SECRET: getEnvString("LIVEKIT_API_SECRET", ""),
  LIVEKIT_HOST: getEnvString("LIVEKIT_HOST", ""),

  // --------------------------------------------------------------------------
  // Redis
  // --------------------------------------------------------------------------
  REDIS_URL: getEnvString("REDIS_URL", ""),
  REDIS_HOST: getEnvString("REDIS_HOST", "localhost"),
  REDIS_PORT: getEnvNumber("REDIS_PORT", 6379),
  REDIS_PASSWORD: getEnvString("REDIS_PASSWORD", ""),
  REDIS_DB: getEnvNumber("REDIS_DB", 0),

  // --------------------------------------------------------------------------
  // Kafka
  // --------------------------------------------------------------------------
  KAFKA_BROKERS: getEnvString("KAFKA_BROKERS", "localhost:9092"),
  KAFKA_CLIENT_ID: getEnvString("KAFKA_CLIENT_ID", "votesecure-api"),
  KAFKA_GROUP_ID: getEnvString("KAFKA_GROUP_ID", "votesecure-consumer"),
  KAFKA_SSL: getEnvBoolean("KAFKA_SSL", false),
  KAFKA_SASL_USERNAME: getEnvString("KAFKA_SASL_USERNAME", ""),
  KAFKA_SASL_PASSWORD: getEnvString("KAFKA_SASL_PASSWORD", ""),

  // --------------------------------------------------------------------------
  // BullMQ
  // --------------------------------------------------------------------------
  BULLMQ_REDIS_URL: getEnvString("BULLMQ_REDIS_URL", ""),

  // --------------------------------------------------------------------------
  // Cloudinary (Avatars / Campaign Images)
  // --------------------------------------------------------------------------
  CLOUDINARY_CLOUD_NAME: getEnvString("CLOUDINARY_CLOUD_NAME", ""),
  CLOUDINARY_API_KEY: getEnvString("CLOUDINARY_API_KEY", ""),
  CLOUDINARY_API_SECRET: getEnvString("CLOUDINARY_API_SECRET", ""),

  // --------------------------------------------------------------------------
  // SMTP / Email
  // --------------------------------------------------------------------------
  SMTP_HOST: getEnvString("SMTP_HOST", ""),
  SMTP_PORT: getEnvNumber("SMTP_PORT", 587),
  SMTP_USER: getEnvString("SMTP_USER", ""),
  SMTP_PASS: getEnvString("SMTP_PASS", ""),
  SMTP_FROM: getEnvString("SMTP_FROM", "noreply@votesecure.app"),

  // --------------------------------------------------------------------------
  // Observability
  // --------------------------------------------------------------------------
  LOG_LEVEL: getEnvString("LOG_LEVEL", "info"),
  SENTRY_DSN: getEnvString("SENTRY_DSN", ""),
  PROMETHEUS_METRICS_ENABLED: getEnvBoolean("PROMETHEUS_METRICS_ENABLED", true),

  // --------------------------------------------------------------------------
  // JWT (internal service tokens)
  // --------------------------------------------------------------------------
  JWT_SECRET: getEnvString("JWT_SECRET", "change-me-in-production"),
  JWT_EXPIRY: getEnvString("JWT_EXPIRY", "7d"),

  // --------------------------------------------------------------------------
  // Blockchain (Ethereum / Polygon / zkSync)
  // --------------------------------------------------------------------------
  BLOCKCHAIN_RPC_URL: getEnvString("BLOCKCHAIN_RPC_URL", ""),
  BLOCKCHAIN_RPC_URL_POLYGON: getEnvString("BLOCKCHAIN_RPC_URL_POLYGON", ""),
  BLOCKCHAIN_RPC_URL_ZKSYNC: getEnvString("BLOCKCHAIN_RPC_URL_ZKSYNC", ""),
  BLOCKCHAIN_PRIVATE_KEY: getEnvString("BLOCKCHAIN_PRIVATE_KEY", ""),
  BLOCKCHAIN_CHAIN_ID: getEnvNumber("BLOCKCHAIN_CHAIN_ID", 1),
  ALCHEMY_API_KEY: getEnvString("ALCHEMY_API_KEY", ""),
  INFURA_API_KEY: getEnvString("INFURA_API_KEY", ""),

  // --------------------------------------------------------------------------
  // Smart Contract Addresses (UUPS Proxies — deployed by Foundry)
  // --------------------------------------------------------------------------
  CONTRACT_IDENTITY_REGISTRY: getEnvString("CONTRACT_IDENTITY_REGISTRY", ""),
  CONTRACT_REGION_REGISTRY: getEnvString("CONTRACT_REGION_REGISTRY", ""),
  CONTRACT_ELECTION_FACTORY: getEnvString("CONTRACT_ELECTION_FACTORY", ""),
  CONTRACT_VOTE_PROTOCOL: getEnvString("CONTRACT_VOTE_PROTOCOL", ""),
  CONTRACT_VOTE_FEE_ESCROW: getEnvString("CONTRACT_VOTE_FEE_ESCROW", ""),
  CONTRACT_CANDIDATE_REGISTRY: getEnvString("CONTRACT_CANDIDATE_REGISTRY", ""),
  CONTRACT_PARTY_REGISTRY: getEnvString("CONTRACT_PARTY_REGISTRY", ""),
  CONTRACT_FORUM_GOVERNANCE: getEnvString("CONTRACT_FORUM_GOVERNANCE", ""),
  CONTRACT_FRAUD_DETECTION: getEnvString("CONTRACT_FRAUD_DETECTION", ""),
  CONTRACT_ZK_VERIFIER: getEnvString("CONTRACT_ZK_VERIFIER", ""),

  // --------------------------------------------------------------------------
  // Payment / Crypto Escrow
  // --------------------------------------------------------------------------
  VOTE_FEE_USD_CENTS: getEnvNumber("VOTE_FEE_USD_CENTS", 100), // $1.00 default
  SUPPORTED_PAYMENT_TOKENS: getEnvString("SUPPORTED_PAYMENT_TOKENS", "USDT,USDC,ETH"),
  USDT_CONTRACT_ADDRESS: getEnvString("USDT_CONTRACT_ADDRESS", ""),
  USDC_CONTRACT_ADDRESS: getEnvString("USDC_CONTRACT_ADDRESS", ""),

  // --------------------------------------------------------------------------
  // AI / FastAPI Intelligence Plane
  // --------------------------------------------------------------------------
  AI_SERVICE_URL: getEnvString("AI_SERVICE_URL", "http://localhost:8000/api/v1"),
  AI_INTERNAL_API_KEY: getEnvString("AI_INTERNAL_API_KEY", ""),

  // --------------------------------------------------------------------------
  // IPFS / Filecoin (Manifesto & Evidence Storage)
  // --------------------------------------------------------------------------
  IPFS_API_URL: getEnvString("IPFS_API_URL", ""),
  IPFS_GATEWAY_URL: getEnvString("IPFS_GATEWAY_URL", "https://ipfs.io/ipfs"),
  WEB3_STORAGE_TOKEN: getEnvString("WEB3_STORAGE_TOKEN", ""),

  // --------------------------------------------------------------------------
  // GeoIP
  // --------------------------------------------------------------------------
  GEOIP_DB_PATH: getEnvString("GEOIP_DB_PATH", ""),
  ENFORCE_REGION_LOCK: getEnvBoolean("ENFORCE_REGION_LOCK", true),
};

// ============================================================================
// ENVIRONMENT CHECKS
// ============================================================================

export function isProduction() {
  return env.NODE_ENV === "production";
}

export function isDevelopment() {
  return env.NODE_ENV === "development";
}

export function isTest() {
  return env.NODE_ENV === "test";
}

export function validateEnv() {
  const required = ["DATABASE_URL", "JWT_SECRET"];
  const recommended = [
    "FIREBASE_SERVICE_ACCOUNT",
    "REDIS_HOST",
    "BLOCKCHAIN_RPC_URL",
    "CONTRACT_IDENTITY_REGISTRY",
    "CONTRACT_ELECTION_FACTORY",
    "CONTRACT_VOTE_PROTOCOL",
    "CONTRACT_VOTE_FEE_ESCROW",
    "AI_SERVICE_URL",
    "AI_INTERNAL_API_KEY",
  ];

  const missing = required.filter((key) => !process.env[key]);
  const missingRecommended = recommended.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    console.error(`[Config] Missing REQUIRED env vars: ${missing.join(", ")}`);
  }

  if (missingRecommended.length > 0 && env.NODE_ENV === "production") {
    console.warn(`[Config] Missing recommended env vars: ${missingRecommended.join(", ")}`);
  }

  return { valid: missing.length === 0, missing };
}

export default env;