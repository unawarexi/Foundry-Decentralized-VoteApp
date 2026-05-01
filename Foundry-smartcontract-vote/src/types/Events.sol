// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "./DataTypes.sol";

// Events — all event definitions for the VoteSecure protocol

// ──────────────────────────────────────────────────────────────────────────────
//  IDENTITY EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__VoterRegistered(
    address indexed wallet,
    bytes32 indexed identityHash,
    bytes32 indexed regionHash,
    DataTypes.VerificationLevel level,
    uint64 timestamp
);

event Events__VoterBanned(address indexed voter, bytes32 evidenceHash, address indexed by, uint64 timestamp);
event Events__VoterUnbanned(address indexed voter, address indexed by, uint64 timestamp);
event Events__VoterVerificationUpgraded(
    address indexed voter,
    DataTypes.VerificationLevel oldLevel,
    DataTypes.VerificationLevel newLevel,
    uint64 timestamp
);

// ──────────────────────────────────────────────────────────────────────────────
//  ELECTION EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__ElectionCreated(
    uint256 indexed electionId,
    bytes32 indexed regionHash,
    DataTypes.ElectionType electionType,
    address indexed creator,
    uint64 startTime,
    uint64 endTime
);

event Events__ElectionActivated(uint256 indexed electionId, uint64 timestamp);
event Events__ElectionPaused(uint256 indexed electionId, address indexed by, string reason);
event Events__ElectionResumed(uint256 indexed electionId, address indexed by);
event Events__ElectionCancelled(uint256 indexed electionId, address indexed by, string reason);
event Events__ElectionTallyStarted(uint256 indexed electionId, uint64 timestamp);
event Events__ElectionFinalized(
    uint256 indexed electionId,
    uint256 indexed winnerCandidateId,
    uint256 winnerVoteCount,
    uint256 totalVotes,
    uint64 timestamp
);

// ──────────────────────────────────────────────────────────────────────────────
//  VOTE EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__VoteCast(
    uint256 indexed electionId,
    uint256 indexed candidateId,
    bytes32 indexed voteHash,          // anonymised — no voter address
    bool isRevote,
    uint64 timestamp
);

event Events__RevoteAllowed(uint256 indexed electionId, address indexed voter, uint64 timestamp);

// ──────────────────────────────────────────────────────────────────────────────
//  CANDIDATE EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__CandidateRegistered(
    uint256 indexed candidateId,
    uint256 indexed electionId,
    address indexed wallet,
    bytes32 partyId,
    uint64 timestamp
);

event Events__CandidateVerified(uint256 indexed candidateId, uint64 timestamp);
event Events__CandidateDisqualified(uint256 indexed candidateId, address indexed by, bytes32 reason, uint64 timestamp);
event Events__CandidateWithdrawn(uint256 indexed candidateId, uint64 timestamp);
event Events__CandidatePopularityUpdated(uint256 indexed candidateId, uint256 oldScore, uint256 newScore);
event Events__ManifestoUpdated(uint256 indexed candidateId, bytes32 newIpfsHash, uint64 timestamp);

// ──────────────────────────────────────────────────────────────────────────────
//  PAYMENT EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__FeePaid(
    address indexed voter,
    uint256 indexed electionId,
    address indexed token,
    uint256 amount,
    uint64 timestamp
);

event Events__FeeReleased(address indexed voter, uint256 indexed electionId, address indexed treasury, uint256 amount);
event Events__FeeRefunded(address indexed voter, uint256 indexed electionId, uint256 amount, string reason);
event Events__TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

// ──────────────────────────────────────────────────────────────────────────────
//  FORUM EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__QuestionAsked(
    uint256 indexed questionId,
    uint256 indexed electionId,
    uint256 indexed candidateId,
    address asker,
    bytes32 contentIpfsHash,
    uint64 deadline
);

event Events__QuestionAnswered(
    uint256 indexed questionId,
    uint256 indexed candidateId,
    bytes32 answerIpfsHash,
    uint64 timestamp
);

event Events__QuestionUpvoted(uint256 indexed questionId, address indexed voter, uint256 newTotal);
event Events__QuestionDownvoted(uint256 indexed questionId, address indexed voter, uint256 newTotal);
event Events__SLAPenaltyApplied(uint256 indexed questionId, uint256 indexed candidateId, int256 popularityDelta);

// ──────────────────────────────────────────────────────────────────────────────
//  PARTY EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__PartyRegistered(bytes32 indexed partyId, string name, bytes32 indexed regionHash, address indexed registrar);
event Events__PartyDeactivated(bytes32 indexed partyId, address indexed by);
event Events__PartyMemberAdded(bytes32 indexed partyId, address indexed member);
event Events__PartyMemberRemoved(bytes32 indexed partyId, address indexed member);

// ──────────────────────────────────────────────────────────────────────────────
//  FRAUD EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__FraudFlagRaised(
    uint256 indexed flagId,
    address indexed target,
    DataTypes.FraudSeverity severity,
    bytes32 evidenceHash,
    address indexed reporter,
    uint64 timestamp
);

event Events__FraudFlagResolved(uint256 indexed flagId, address indexed resolver, uint64 timestamp);

// ──────────────────────────────────────────────────────────────────────────────
//  REGION EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__RegionRegistered(bytes32 indexed regionId, string countryISO, string regionCode);
event Events__RegionDeactivated(bytes32 indexed regionId);

// ──────────────────────────────────────────────────────────────────────────────
//  GOVERNANCE EVENTS
// ──────────────────────────────────────────────────────────────────────────────

event Events__ProposalCreated(uint256 indexed proposalId, address indexed proposer, bytes32 descriptionHash);
event Events__ProposalExecuted(uint256 indexed proposalId, uint64 timestamp);
event Events__ProtocolFeeUpdated(uint256 oldFee, uint256 newFee);
event Events__BackendSignerUpdated(address indexed oldSigner, address indexed newSigner);
event Events__ContractUpgraded(address indexed proxy, address indexed newImplementation, uint64 timestamp);
