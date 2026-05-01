// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Errors — all custom error definitions for the VoteSecure protocol
// Using custom errors saves ~50% gas vs require(bool, string)

// ──────────────────────────────────────────────────────────────────────────────
//  IDENTITY & VOTER ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Voter is not registered in the system
error Errors__VoterNotRegistered(address voter);

/// @notice Voter is banned from participating
error Errors__VoterBanned(address voter);

/// @notice Voter's identity hash does not match on-chain record
error Errors__IdentityMismatch(address voter, bytes32 expected, bytes32 provided);

/// @notice Voter's biometric verification has expired or is invalid
error Errors__BiometricExpired(address voter, uint64 expiredAt);

/// @notice Voter does not meet minimum verification level for this election
error Errors__InsufficientVerificationLevel(address voter, uint8 required, uint8 provided);

/// @notice Voter is from a different region and cannot vote in this election
error Errors__RegionMismatch(bytes32 voterRegion, bytes32 electionRegion);

/// @notice Voter has already voted in this election (and revoting is disabled)
error Errors__AlreadyVoted(address voter, uint256 electionId);

/// @notice Voter is attempting to register with an already-used identity hash
error Errors__IdentityAlreadyRegistered(bytes32 identityHash);

/// @notice Backend signer signature is invalid or reused
error Errors__InvalidSignature();

/// @notice Signature has expired
error Errors__SignatureExpired(uint64 deadline, uint64 currentTime);

/// @notice Replay protection: nonce already used
error Errors__NonceUsed(bytes32 nonce);

// ──────────────────────────────────────────────────────────────────────────────
//  ELECTION ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Election does not exist
error Errors__ElectionNotFound(uint256 electionId);

/// @notice Election is not in ACTIVE status for this operation
error Errors__ElectionNotActive(uint256 electionId);

/// @notice Election voting window has not opened yet
error Errors__ElectionNotStarted(uint256 electionId, uint64 startTime);

/// @notice Election voting window has closed
error Errors__ElectionEnded(uint256 electionId, uint64 endTime);

/// @notice Election is already finalized
error Errors__ElectionAlreadyFinalized(uint256 electionId);

/// @notice Election is already cancelled
error Errors__ElectionAlreadyCancelled(uint256 electionId);

/// @notice Only the election creator may perform this action
error Errors__NotElectionCreator(address caller, address creator);

/// @notice Election end time must be after start time
error Errors__InvalidElectionWindow(uint64 start, uint64 end);

/// @notice Election requires minimum number of candidates
error Errors__InsufficientCandidates(uint256 electionId, uint256 count, uint256 minimum);

/// @notice Election has already been tallied
error Errors__AlreadyTallied(uint256 electionId);

// ──────────────────────────────────────────────────────────────────────────────
//  CANDIDATE ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Candidate does not exist
error Errors__CandidateNotFound(uint256 candidateId);

/// @notice Candidate is not active in this election
error Errors__CandidateNotActive(uint256 candidateId);

/// @notice Candidate is not part of the specified election
error Errors__CandidateNotInElection(uint256 candidateId, uint256 electionId);

/// @notice Candidate already registered in this election
error Errors__CandidateAlreadyRegistered(address candidate, uint256 electionId);

/// @notice Candidate profile IPFS hash is empty
error Errors__MissingCandidateProfile();

/// @notice Candidate identity has not been verified
error Errors__CandidateNotVerified(uint256 candidateId);

// ──────────────────────────────────────────────────────────────────────────────
//  PAYMENT / FEE ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Insufficient token allowance granted to the escrow contract
error Errors__InsufficientAllowance(address token, uint256 required, uint256 provided);

/// @notice Insufficient token balance
error Errors__InsufficientBalance(address token, uint256 required, uint256 provided);

/// @notice Fee amount does not match protocol requirement
error Errors__IncorrectFeeAmount(uint256 required, uint256 provided);

/// @notice Token not accepted for this election
error Errors__TokenNotAccepted(address token);

/// @notice Fee transfer failed
error Errors__FeeTransferFailed();

/// @notice Escrow not found
error Errors__EscrowNotFound(address voter, uint256 electionId);

/// @notice Escrow already released
error Errors__EscrowAlreadyReleased(address voter, uint256 electionId);

/// @notice Treasury address cannot be zero
error Errors__ZeroTreasuryAddress();

// ──────────────────────────────────────────────────────────────────────────────
//  FORUM ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Question does not exist
error Errors__QuestionNotFound(uint256 questionId);

/// @notice Question SLA has not yet expired — cannot apply penalty
error Errors__SLANotExpired(uint256 questionId, uint64 deadline);

/// @notice Question is already closed
error Errors__QuestionAlreadyClosed(uint256 questionId);

/// @notice Only the candidate may answer their own question
error Errors__OnlyCandidateCanAnswer(uint256 questionId);

/// @notice Question content hash is missing
error Errors__MissingQuestionContent();

// ──────────────────────────────────────────────────────────────────────────────
//  FRAUD / MODERATION ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Flag does not exist
error Errors__FlagNotFound(uint256 flagId);

/// @notice Target is already banned
error Errors__AlreadyBanned(address target);

/// @notice Target is not banned — cannot unban
error Errors__NotBanned(address target);

/// @notice Only designated fraud oracle may submit flags
error Errors__NotFraudOracle(address caller);

// ──────────────────────────────────────────────────────────────────────────────
//  ACCESS CONTROL ERRORS
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Caller is not authorized
error Errors__Unauthorized(address caller, bytes32 requiredRole);

/// @notice Zero address provided where non-zero required
error Errors__ZeroAddress();

/// @notice Array length mismatch between two parameters
error Errors__ArrayLengthMismatch(uint256 a, uint256 b);

/// @notice Value is out of acceptable bounds
error Errors__OutOfBounds(uint256 value, uint256 min, uint256 max);

/// @notice Contract is paused
error Errors__ContractPaused();

/// @notice Initializer already called
error Errors__AlreadyInitialized();

/// @notice Deadline is in the past
error Errors__DeadlineInPast(uint64 deadline);

/// @notice Region is not active
error Errors__RegionNotActive(bytes32 regionHash);
