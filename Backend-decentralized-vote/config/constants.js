// ============================================================================
// VoteSecure — Application Constants
// ============================================================================

// ============================================================================
// HTTP STATUS CODES
// ============================================================================

export const HttpStatus = {
  OK: 200,
  CREATED: 201,
  ACCEPTED: 202,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  PAYMENT_REQUIRED: 402,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  LOCKED: 423,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
};

// ============================================================================
// ERROR CODES
// ============================================================================

export const ErrorCodes = {
  // Auth & Identity
  UNAUTHORIZED: "E1001",
  TOKEN_INVALID: "E1002",
  FORBIDDEN: "E1003",
  TOKEN_EXPIRED: "E1004",
  ACCOUNT_SUSPENDED: "E1005",
  ACCOUNT_DEACTIVATED: "E1006",
  FIREBASE_AUTH_FAILED: "E1007",
  KYC_REQUIRED: "E1008",
  BIOMETRIC_MISMATCH: "E1009",
  WALLET_NOT_CONNECTED: "E1010",
  DEVICE_NOT_FOUND: "E1011",
  WALLET_ALREADY_LINKED: "E1011",

  // Validation
  VALIDATION_ERROR: "E2001",
  INVALID_INPUT: "E2002",
  MISSING_FIELD: "E2003",
  INVALID_WALLET_ADDRESS: "E2004",
  INVALID_SIGNATURE: "E2005",
  INVALID_CHAIN_ID: "E2006",

  // Resources
  USER_NOT_FOUND: "E3001",
  USER_ALREADY_EXISTS: "E3002",
  ELECTION_NOT_FOUND: "E3003",
  CANDIDATE_NOT_FOUND: "E3004",
  REGION_NOT_FOUND: "E3005",
  PARTY_NOT_FOUND: "E3006",
  VOTE_NOT_FOUND: "E3007",
  NOTIFICATION_NOT_FOUND: "E3008",
  FORUM_POST_NOT_FOUND: "E3009",
  FRAUD_REPORT_NOT_FOUND: "E3010",

  // Voting Business Logic
  VOTER_NOT_REGISTERED: "E4001",
  VOTER_BANNED: "E4002",
  REGION_MISMATCH: "E4003",
  ELECTION_NOT_ACTIVE: "E4004",
  ALREADY_VOTED: "E4005",
  INVALID_CANDIDATE: "E4006",
  INSUFFICIENT_FEE: "E4007",
  CANDIDATE_NOT_APPROVED: "E4008",
  PARTY_NOT_ACTIVE: "E4009",
  ELECTION_REGISTRATION_CLOSED: "E4010",
  ELECTION_PHASE_ERROR: "E4011",
  DUPLICATE_CANDIDATE_ENTRY: "E4012",
  SLA_BREACH: "E4013",
  FORUM_POST_EXPIRED: "E4014",
  FORUM_ALREADY_ANSWERED: "E4015",
  FRAUD_FLAG_SUBMITTED: "E4016",
  FRAUD_ALREADY_REPORTED: "E4017",

  // Blockchain
  BLOCKCHAIN_TX_FAILED: "E5001",
  BLOCKCHAIN_REVERT: "E5002",
  BLOCKCHAIN_TIMEOUT: "E5003",
  ON_CHAIN_REGISTRATION_FAILED: "E5004",
  NULLIFIER_ALREADY_USED: "E5005",
  CONTRACT_CALL_FAILED: "E5006",

  // Payment
  PAYMENT_NOT_CONFIRMED: "E6001",
  PAYMENT_INSUFFICIENT: "E6002",
  PAYMENT_TOKEN_UNSUPPORTED: "E6003",
  REFUND_FAILED: "E6004",

  // Rate Limiting
  RATE_LIMIT_EXCEEDED: "E8001",

  // Server
  INTERNAL_ERROR: "E9001",
  SERVICE_UNAVAILABLE: "E9002",
  AI_SERVICE_DOWN: "E9003",
  BLOCKCHAIN_SERVICE_DOWN: "E9004",
};

// ============================================================================
// ELECTION CONFIGURATION
// ============================================================================

export const ElectionConfig = {
  MIN_CANDIDATES: 2,
  MAX_CANDIDATES: 500,
  SLA_HOURS: 24,          // candidate must answer forum questions within 24h
  SLA_WARNING_HOURS: 18,  // warning sent at 18h
  MAX_DESCRIPTION_LENGTH: 5000,
  DEFAULT_VOTE_FEE_CENTS: 100, // $1.00
  RESULT_HASH_ALGO: "keccak256",
};

// ============================================================================
// VOTE CONFIGURATION
// ============================================================================

export const VoteConfig = {
  FEE_CONFIRMATION_BLOCKS: 6,
  TX_TIMEOUT_MS: 90000, // 90 seconds to confirm tx
  NULLIFIER_PREFIX: "vsec-vote-",
};

// ============================================================================
// FORUM CONFIGURATION
// ============================================================================

export const ForumConfig = {
  MAX_QUESTION_LENGTH: 1000,
  MAX_ANSWER_LENGTH: 5000,
  VOTE_DEBOUNCE_MS: 1000, // prevent rapid up/down voting
};

// ============================================================================
// FRAUD CONFIGURATION
// ============================================================================

export const FraudConfig = {
  AI_RISK_THRESHOLD_MEDIUM: 0.5,
  AI_RISK_THRESHOLD_HIGH: 0.75,
  AI_RISK_THRESHOLD_CRITICAL: 0.9,
  AUTO_BAN_THRESHOLD: 0.95, // auto-ban if AI score above this
};

// ============================================================================
// BLOCKCHAIN CONFIGURATION
// ============================================================================

export const BlockchainConfig = {
  CONFIRMATION_BLOCKS: 3,
  GAS_LIMIT_VOTE: 200000,
  GAS_LIMIT_REGISTER: 300000,
  GAS_LIMIT_ELECTION: 500000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY_MS: 2000,
};

// ============================================================================
// PAYMENT CONFIGURATION
// ============================================================================

export const PaymentConfig = {
  SUPPORTED_TOKENS: ["USDT", "USDC", "ETH"],
  CONFIRMATION_BLOCKS: 6,
  ESCROW_TIMEOUT_MS: 300000, // 5 minutes to complete payment
  MIN_FEE_CENTS: 50,   // $0.50
  MAX_FEE_CENTS: 10000, // $100
};

// ============================================================================
// KYC LEVELS
// ============================================================================

export const KYCLevel = {
  NONE: 0,
  EMAIL_VERIFIED: 1,
  PHONE_VERIFIED: 2,
  DOCUMENT_SUBMITTED: 3,
  BIOMETRIC_VERIFIED: 4,
  FULLY_VERIFIED: 5,
};

// ============================================================================
// RATE LIMITING
// ============================================================================

export const RateLimits = {
  API: { windowMs: 15 * 60 * 1000, max: 200 },
  AUTH: { windowMs: 15 * 60 * 1000, max: 20 },
  VOTE_CAST: { windowMs: 60 * 1000, max: 3 },
  CANDIDATE_REGISTER: { windowMs: 60 * 60 * 1000, max: 5 },
  FORUM_POST: { windowMs: 60 * 1000, max: 10 },
  FRAUD_REPORT: { windowMs: 60 * 60 * 1000, max: 5 },
  UPLOAD: { windowMs: 60 * 1000, max: 10 },
  WALLET: { windowMs: 60 * 1000, max: 20 },
  NOTIFICATION: { windowMs: 60 * 1000, max: 30 },
};

// ============================================================================
// CACHE TTL (in seconds)
// ============================================================================

export const CacheTTL = {
  USER_PROFILE: 300,         // 5 min
  ELECTION_LIST: 60,         // 1 min
  ELECTION_DETAIL: 120,      // 2 min
  ELECTION_RESULTS: 3600,    // 1 hour (immutable after finalized)
  CANDIDATE_LIST: 120,
  PARTY_LIST: 600,
  REGION_LIST: 3600,         // 1 hour (rarely changes)
  ANALYTICS: 300,            // 5 min
  FORUM_POSTS: 60,
  NOTIFICATIONS: 30,
  BLOCKCHAIN_STATUS: 30,
};

// ============================================================================
// SOCKET EVENTS
// ============================================================================

export const SocketEvents = {
  // Connection
  CONNECTION: "connection",
  DISCONNECT: "disconnect",
  ERROR: "error",

  // Election real-time
  ELECTION_STARTED: "election:started",
  ELECTION_ENDED: "election:ended",
  ELECTION_PHASE_CHANGED: "election:phase_changed",
  ELECTION_RESULTS_LIVE: "election:results_live",
  VOTE_CAST: "vote:cast",
  VOTE_COUNT_UPDATED: "vote:count_updated",

  // Forum real-time
  FORUM_NEW_QUESTION: "forum:new_question",
  FORUM_QUESTION_ANSWERED: "forum:question_answered",
  FORUM_SLA_WARNING: "forum:sla_warning",
  FORUM_SLA_BREACH: "forum:sla_breach",

  // Fraud real-time
  FRAUD_FLAG_RAISED: "fraud:flag_raised",
  FRAUD_USER_BANNED: "fraud:user_banned",

  // Notifications
  NOTIFICATION: "notification:received",
  NOTIFICATION_READ: "notification:read",

  // Blockchain confirmations
  TX_PENDING: "tx:pending",
  TX_CONFIRMED: "tx:confirmed",
  TX_FAILED: "tx:failed",

  // User presence
  USER_ONLINE: "user:online",
  USER_OFFLINE: "user:offline",

  // Admin
  ADMIN_BROADCAST: "admin:broadcast",
  ADMIN_ELECTION_UPDATE: "admin:election_update",

  // Voice Assistant (Client ↔ Express ↔ FastAPI)
  AI_VOICE_COMMAND: "ai:voice_command",
  AI_VOICE_COMMAND_RESULT: "ai:voice_command_result",
  AI_VOICE_COMMAND_CONFIRM: "ai:voice_command_confirm",
  AI_TOOL_EXECUTE: "ai:tool_execute",
  AI_TOOL_RESULT: "ai:tool_result",
  AI_WORKFLOW_STATUS: "ai:workflow_status",
};

// ============================================================================
// KAFKA TOPICS
// ============================================================================

export const KafkaTopics = {
  MEETING_EVENTS: "speakup.meeting.events",
  PARTICIPANT_EVENTS: "speakup.participant.events",
  CHAT_MESSAGES: "speakup.chat.messages",
  RECORDING_EVENTS: "speakup.recording.events",
  NOTIFICATION_EVENTS: "speakup.notification.events",
  ANALYTICS_EVENTS: "speakup.analytics.events",
  USER_EVENTS: "speakup.user.events",

  // AI topics (produced by FastAPI, consumed by Express for real-time delivery)
  AI_TRANSCRIPTION: "speakup.ai.transcription",
  AI_LIVE_INSIGHTS: "speakup.ai.live_insights",
  AI_EMOTION_SIGNALS: "speakup.ai.emotion_signals",
  AI_COACHING_HINTS: "speakup.ai.coaching_hints",
  AI_COPILOT_SUGGESTIONS: "speakup.ai.copilot_suggestions",
  AI_MEETING_SUMMARY: "speakup.ai.meeting_summary",
  AI_ACTION_ITEMS: "speakup.ai.action_items",
  AI_MEMORY_UPDATES: "speakup.ai.memory_updates",
  AI_CV_ANALYSIS: "speakup.ai.cv_analysis",

  // Media stream topics (Express → FastAPI)
  MEDIA_AUDIO_CHUNKS: "speakup.media.audio_chunks",
  MEDIA_VIDEO_FRAMES: "speakup.media.video_frames",
};

// ============================================================================
// BULLMQ QUEUES
// ============================================================================

export const BullQueues = {
  EMAIL: "speakup-email",
  NOTIFICATION: "speakup-notification",
  RECORDING: "speakup-recording",
  ANALYTICS: "speakup-analytics",
  CLEANUP: "speakup-cleanup",
};

// ============================================================================
// PAGINATION DEFAULTS
// ============================================================================

export const Pagination = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
};

// ============================================================================
// HEADERS
// ============================================================================

export const Headers = {
  REQUEST_ID: "x-request-id",
  USER_AGENT: "user-agent",
  PLATFORM: "x-platform",
};

export const AppLinks = {
  GOOGLE_PLAY: "https://play.google.com/store/apps/details?id=com.speakup.conference",
  APPLE_STORE: "https://apps.apple.com/app/speakup-conference/id0000000000",
  WEB_APP: process.env.FRONTEND_URL || "https://speakup.app",
};

export default {
  HttpStatus,
  ErrorCodes,
  MeetingConfig,
  RateLimits,
  CacheTTL,
  SocketEvents,
  KafkaTopics,
  BullQueues,
  Pagination,
  Headers,
  AppLinks,
};