// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Constants
/// @notice Protocol-wide immutable constants
library Constants {
    // ─── Roles ───────────────────────────────────────────────────
    bytes32 internal constant ADMIN_ROLE            = keccak256("ADMIN_ROLE");
    bytes32 internal constant OPERATOR_ROLE         = keccak256("OPERATOR_ROLE");
    bytes32 internal constant MODERATOR_ROLE        = keccak256("MODERATOR_ROLE");
    bytes32 internal constant FRAUD_ORACLE_ROLE     = keccak256("FRAUD_ORACLE_ROLE");
    bytes32 internal constant BACKEND_SIGNER_ROLE   = keccak256("BACKEND_SIGNER_ROLE");
    bytes32 internal constant UPGRADER_ROLE         = keccak256("UPGRADER_ROLE");
    bytes32 internal constant ELECTION_CREATOR_ROLE = keccak256("ELECTION_CREATOR_ROLE");
    bytes32 internal constant TALLY_ROLE            = keccak256("TALLY_ROLE");

    // ─── Time constants ──────────────────────────────────────────
    uint64 internal constant QUESTION_SLA           = 24 hours;
    uint64 internal constant SIGNATURE_VALIDITY     = 15 minutes;
    uint64 internal constant MIN_ELECTION_DURATION  = 1 hours;
    uint64 internal constant MAX_ELECTION_DURATION  = 365 days;
    uint64 internal constant DISPUTE_PERIOD         = 24 hours;

    // ─── Fee constants (in USD cents) ────────────────────────────
    uint256 internal constant DEFAULT_VOTE_FEE_CENTS   = 100;  // $1.00
    uint256 internal constant MIN_VOTE_FEE_CENTS       = 10;   // $0.10
    uint256 internal constant MAX_VOTE_FEE_CENTS       = 10_000; // $100.00
    uint256 internal constant PROTOCOL_FEE_BPS         = 500;  // 5% of escrow to treasury
    uint256 internal constant BPS_DENOMINATOR          = 10_000;

    // ─── Forum constants ─────────────────────────────────────────
    int256  internal constant SLA_MISS_PENALTY         = -50;   // popularity score delta
    int256  internal constant GOOD_ANSWER_REWARD       = 10;
    int256  internal constant BAD_ANSWER_PENALTY       = -20;
    uint256 internal constant MAX_QUESTIONS_PER_VOTER  = 5;     // per election
    uint256 internal constant MIN_UPVOTES_TO_FEATURE   = 10;

    // ─── Election constants ───────────────────────────────────────
    uint256 internal constant MAX_CANDIDATES_PER_ELECTION = 100;
    uint256 internal constant MIN_CANDIDATES_PER_ELECTION = 2;
    uint256 internal constant MAX_ELECTIONS_PER_REGION    = 10; // concurrent

    // ─── Verification constants ───────────────────────────────────
    uint8   internal constant MIN_VERIFICATION_LEVEL      = 3;  // BIOMETRIC required by default
    uint64  internal constant BIOMETRIC_VALIDITY_PERIOD   = 365 days;

    // ─── Popularity scoring ───────────────────────────────────────
    uint256 internal constant INITIAL_POPULARITY_SCORE    = 500; // out of 1000
    uint256 internal constant MAX_POPULARITY_SCORE        = 1000;

    // ─── Misc ─────────────────────────────────────────────────────
    uint256 internal constant MAX_BATCH_SIZE               = 100;
    bytes32 internal constant ZERO_HASH                    = bytes32(0);
    address internal constant NATIVE_TOKEN                 = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
}
