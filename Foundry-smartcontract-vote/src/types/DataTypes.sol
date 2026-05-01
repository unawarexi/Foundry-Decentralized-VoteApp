// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title DataTypes
/// @notice Shared struct and enum definitions for the VoteSecure protocol
library DataTypes {
    // ─────────────────────────────────────────────────────────────
    //  ENUMS
    // ─────────────────────────────────────────────────────────────

    /// @notice Voter identity verification tier
    enum VerificationLevel {
        NONE,         // 0 – unverified
        EMAIL,        // 1 – email only
        PHONE,        // 2 – phone verified
        BIOMETRIC,    // 3 – face + liveness + ID matched
        ZK_PROOF      // 4 – ZK identity proof verified
    }

    /// @notice Status lifecycle of an election
    enum ElectionStatus {
        PENDING,      // 0 – created, not yet open
        ACTIVE,       // 1 – voting window open
        PAUSED,       // 2 – temporarily halted (emergency)
        TALLYING,     // 3 – voting closed, results processing
        FINALIZED,    // 4 – results published on-chain
        CANCELLED     // 5 – cancelled before or during
    }

    /// @notice Type of the election — determines eligibility rules
    enum ElectionType {
        SCHOOL,
        UNIVERSITY,
        COMPANY,
        LOCAL_GOVERNMENT,
        MAYORAL,
        GUBERNATORIAL,
        NATIONAL,
        UNION,
        COOPERATIVE,
        CUSTOM
    }

    /// @notice Supported payment tokens for the voting fee
    enum PaymentToken {
        USDT,
        USDC,
        ETH   // native ETH equivalent at protocol rate
    }

    /// @notice Candidate standing in their election
    enum CandidateStatus {
        PENDING,
        ACTIVE,
        DISQUALIFIED,
        WITHDRAWN
    }

    /// @notice Forum question resolution state
    enum QuestionStatus {
        OPEN,
        ANSWERED,
        UNANSWERED_EXPIRED,  // 24h SLA missed — auto penalty applied
        CLOSED
    }

    /// @notice Fraud flag severity
    enum FraudSeverity {
        LOW,
        MEDIUM,
        HIGH,
        CRITICAL
    }

    // ─────────────────────────────────────────────────────────────
    //  STRUCTS
    // ─────────────────────────────────────────────────────────────

    /// @notice Core voter identity record (off-chain hash only — no PII on-chain)
    struct Voter {
        bytes32 identityHash;          // hash(userId + region + verifiedFlag) from FastAPI
        bytes32 regionHash;            // keccak256(countryCode + regionCode)
        VerificationLevel level;
        bool isBanned;
        uint32 totalVotesCast;
        uint64 registeredAt;
        uint64 lastVoteAt;
        address wallet;
    }

    /// @notice Election configuration
    struct Election {
        uint256 id;
        bytes32 regionHash;            // elections are region-locked
        ElectionType electionType;
        ElectionStatus status;
        uint64 startTime;
        uint64 endTime;
        uint64 finalizedAt;
        uint256 totalVotes;
        uint256 voteFeeUSD;            // in cents (100 = $1.00)
        PaymentToken acceptedToken;
        address creator;
        address[] candidates;
        bool requireBiometric;
        bool allowRevote;              // last vote counts mechanic
        uint8 minVerificationLevel;    // minimum VerificationLevel required
    }

    /// @notice Candidate profile (references off-chain IPFS for full data)
    struct Candidate {
        uint256 id;
        uint256 electionId;
        address wallet;
        bytes32 profileIpfsHash;       // IPFS CID of full profile JSON
        bytes32 manifestoIpfsHash;     // IPFS CID of manifesto doc
        CandidateStatus status;
        uint256 voteCount;
        uint256 popularityScore;       // AI-scored, updated by oracle
        uint64 registeredAt;
        bytes32 partyId;
        bool identityVerified;
    }

    /// @notice Individual vote record (stored as hash to preserve voter privacy)
    struct VoteRecord {
        bytes32 voteHash;              // keccak256(voterId + electionId + candidateId + nonce)
        uint256 electionId;
        uint256 candidateId;
        uint64 timestamp;
        uint256 feeAmount;
        PaymentToken feeToken;
        bytes32 identityCommitment;    // ZK commitment or identity hash
        bool isRevote;
    }

    /// @notice Political party record
    struct Party {
        bytes32 id;
        string name;
        bytes32 logoIpfsHash;
        bytes32 manifestoIpfsHash;
        bytes32 regionHash;
        address registrar;
        bool isActive;
        uint64 registeredAt;
        uint256 memberCount;
    }

    /// @notice Forum question posed to a candidate
    struct Question {
        uint256 id;
        uint256 electionId;
        uint256 candidateId;
        address asker;
        bytes32 contentIpfsHash;       // question text stored on IPFS
        QuestionStatus status;
        uint256 upvotes;
        uint256 downvotes;
        uint64 askedAt;
        uint64 answerDeadline;         // askedAt + 24 hours
        uint64 answeredAt;
        bytes32 answerIpfsHash;        // candidate answer on IPFS
        int256 popularityDelta;        // impact on candidateScore
    }

    /// @notice Fraud/risk flag record
    struct FraudFlag {
        uint256 id;
        address target;
        FraudSeverity severity;
        bytes32 evidenceHash;
        address reporter;
        uint64 flaggedAt;
        bool resolved;
        uint64 resolvedAt;
        address resolver;
    }

    /// @notice Escrow record per voter per election
    struct FeeEscrow {
        address voter;
        uint256 electionId;
        uint256 amount;
        PaymentToken token;
        bool released;
        uint64 lockedAt;
    }

    /// @notice Region record
    struct Region {
        bytes32 id;                    // keccak256(countryISO + regionCode)
        string countryISO;             // ISO 3166-1 alpha-2 (e.g. "NG", "US")
        string regionCode;
        bool isActive;
        uint256 registeredVoterCount;
        uint256 activeElectionCount;
    }
}
