// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {DataTypes} from "../types/DataTypes.sol";
import {Constants} from "../types/Constants.sol";
import {Errors__ElectionNotFound,
        Errors__ElectionNotActive,
        Errors__ElectionNotStarted,
        Errors__ElectionEnded,
        Errors__CandidateNotActive,
        Errors__CandidateNotInElection,
        Errors__AlreadyVoted,
        Errors__RegionMismatch,
        Errors__InsufficientVerificationLevel,
        Errors__VoterBanned,
        Errors__VoterNotRegistered,
        Errors__IdentityMismatch,
        Errors__InvalidSignature,
        Errors__SignatureExpired,
        Errors__NonceUsed,
        Errors__ZeroAddress} from "../types/Errors.sol";
import {Events__VoteCast, Events__ElectionFinalized} from "../types/Events.sol";
import {IVoteProtocol} from "../../interfaces/IVoteProtocol.sol";
import {IIdentityRegistry} from "../../interfaces/IIdentityRegistry.sol";
import {IElectionFactory} from "../../interfaces/IElectionFactory.sol";
import {ICandidateRegistry} from "../../interfaces/ICandidateRegistry.sol";
import {IVoteFeeEscrow} from "../../interfaces/IVoteFeeEscrow.sol";

/// @title VoteProtocol
/// @notice Core voting contract. Handles:
///           - Pre-vote eligibility checks (identity, region, level, ban, revote)
///           - Vote hash computation (voter privacy)
///           - Fee escrow coordination
///           - Election tally + winner determination
///
/// @dev SECURITY MODEL:
///   1. FastAPI backend signs every vote authorisation (ECDSA / EIP-712)
///      → Prevents on-chain vote stuffing without backend verification
///   2. Vote stored as keccak256(identityHash + electionId + candidateId + voteNonce)
///      → Voter address never stored in vote record
///   3. Region enforcement: voter.regionHash must equal election.regionHash
///   4. Verification level enforcement: voter.level >= election.minVerificationLevel
///   5. Revote: if allowRevote=true, previous vote is neutralised (voteCount adjusted)
///   6. Nonce: each vote authorisation is single-use (prevents replay)
///   7. Deadline: authorisation expires after SIGNATURE_VALIDITY
///
/// @notice Only one vote per voter per election (unless allowRevote is enabled).
contract VoteProtocol is
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuard,
    PausableUpgradeable,
    UUPSUpgradeable,
    IVoteProtocol
{
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // ─── EIP-712 ─────────────────────────────────────────────────────────────
    bytes32 private constant _VOTE_TYPEHASH = keccak256(
        "Vote(address voter,uint256 electionId,uint256 candidateId,bytes32 identityHash,bytes32 voteNonce,uint64 deadline)"
    );
    bytes32 private _DOMAIN_SEPARATOR;

    // ─── State ───────────────────────────────────────────────────────────────

    IIdentityRegistry public identityRegistry;
    IElectionFactory  public electionFactory;
    ICandidateRegistry public candidateRegistry;
    IVoteFeeEscrow    public feeEscrow;

    /// voter → electionId → VoteRecord
    mapping(address => mapping(uint256 => DataTypes.VoteRecord)) private _votes;

    /// voter → electionId → hasVoted
    mapping(address => mapping(uint256 => bool)) private _hasVoted;

    /// nonce → used
    mapping(bytes32 => bool) private _usedNonces;

    /// electionId → candidateId → voteCount (tally mirror)
    mapping(uint256 => mapping(uint256 => uint256)) private _electionTally;

    uint256 private _totalVotesCast;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(
        address admin,
        address _identityRegistry,
        address _electionFactory,
        address _candidateRegistry,
        address _feeEscrow
    ) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.BACKEND_SIGNER_ROLE, admin); // will be updated to actual signer

        identityRegistry  = IIdentityRegistry(_identityRegistry);
        electionFactory   = IElectionFactory(_electionFactory);
        candidateRegistry = ICandidateRegistry(_candidateRegistry);
        feeEscrow         = IVoteFeeEscrow(_feeEscrow);

        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("VoteSecure"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VOTE CASTING
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Cast a vote.
    ///
    ///   Flow:
    ///     1. Verify backend signature (ensures FastAPI biometric + AI check passed)
    ///     2. Load election + validate timing + status
    ///     3. Load voter + validate registration/ban/region/level
    ///     4. Validate candidate is active and in the election
    ///     5. Check revote rules
    ///     6. Compute vote hash (no PII stored)
    ///     7. Store vote record
    ///     8. Update tally + external state
    ///
    /// @param params  Typed vote parameters including EIP-712 backend signature
    function castVote(CastVoteParams calldata params)
        external
        nonReentrant
        whenNotPaused
    {
        // ── 1. Signature validation ──
        _validateVoteSignature(params);

        // ── 2. Election validation ──
        DataTypes.Election memory election = electionFactory.getElection(params.electionId);
        if (election.id == 0) revert Errors__ElectionNotFound(params.electionId);
        if (election.status != DataTypes.ElectionStatus.ACTIVE) {
            revert Errors__ElectionNotActive(params.electionId);
        }
        if (block.timestamp < election.startTime) {
            revert Errors__ElectionNotStarted(params.electionId, election.startTime);
        }
        if (block.timestamp > election.endTime) {
            revert Errors__ElectionEnded(params.electionId, election.endTime);
        }

        // ── 3. Voter validation ──
        DataTypes.Voter memory voter = identityRegistry.getVoter(msg.sender);
        if (voter.wallet == address(0)) revert Errors__VoterNotRegistered(msg.sender);
        if (voter.isBanned) revert Errors__VoterBanned(msg.sender);
        if (voter.identityHash != params.identityHash) {
            revert Errors__IdentityMismatch(msg.sender, voter.identityHash, params.identityHash);
        }
        if (voter.regionHash != election.regionHash) {
            revert Errors__RegionMismatch(voter.regionHash, election.regionHash);
        }
        if (uint8(voter.level) < election.minVerificationLevel) {
            revert Errors__InsufficientVerificationLevel(
                msg.sender,
                election.minVerificationLevel,
                uint8(voter.level)
            );
        }

        // ── 4. Candidate validation ──
        DataTypes.Candidate memory candidate = candidateRegistry.getCandidate(params.candidateId);
        if (candidate.id == 0) revert Errors__CandidateNotActive(params.candidateId);
        if (candidate.electionId != params.electionId) {
            revert Errors__CandidateNotInElection(params.candidateId, params.electionId);
        }
        if (candidate.status != DataTypes.CandidateStatus.ACTIVE) {
            revert Errors__CandidateNotActive(params.candidateId);
        }

        // ── 5. Revote check ──
        bool isRevote = _hasVoted[msg.sender][params.electionId];
        if (isRevote && !election.allowRevote) {
            revert Errors__AlreadyVoted(msg.sender, params.electionId);
        }

        // If revoting, subtract previous candidate's tally
        if (isRevote) {
            DataTypes.VoteRecord memory prevVote = _votes[msg.sender][params.electionId];
            if (_electionTally[params.electionId][prevVote.candidateId] > 0) {
                _electionTally[params.electionId][prevVote.candidateId]--;
            }
            // Note: CandidateRegistry.voteCount does NOT get decremented on revote
            // (it tracks historical cast, not current standing) — tally is source of truth
        }

        // ── 6. Compute vote hash (privacy — no voter address in record) ──
        bytes32 voteHash = keccak256(
            abi.encodePacked(
                voter.identityHash,
                params.electionId,
                params.candidateId,
                params.voteNonce,
                block.chainid
            )
        );

        // ── 7. Store vote ──
        _usedNonces[params.voteNonce] = true;
        _votes[msg.sender][params.electionId] = DataTypes.VoteRecord({
            voteHash: voteHash,
            electionId: params.electionId,
            candidateId: params.candidateId,
            timestamp: uint64(block.timestamp),
            feeAmount: 0, // populated after fee lock
            feeToken: election.acceptedToken,
            identityCommitment: voter.identityHash,
            isRevote: isRevote
        });
        _hasVoted[msg.sender][params.electionId] = true;

        // ── 8. Update tally + external contracts ──
        _electionTally[params.electionId][params.candidateId]++;
        _totalVotesCast++;

        // Update identity registry vote count
        identityRegistry.recordVoteCast(msg.sender);
        // Increment candidate vote count in registry (for initial cast only)
        if (!isRevote) {
            candidateRegistry.incrementVoteCount(params.candidateId);
        }
        // Increment election total
        electionFactory.incrementVoteCount(params.electionId);

        emit Events__VoteCast(
            params.electionId,
            params.candidateId,
            voteHash,
            isRevote,
            uint64(block.timestamp)
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  TALLY & FINALIZATION
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Finalize an election — determine winner and mark as FINALIZED.
    ///         Called by admin/tally role after election ends.
    function finalizeElection(uint256 electionId)
        external
        onlyRole(Constants.TALLY_ROLE)
    {
        DataTypes.Election memory election = electionFactory.getElection(electionId);
        if (election.id == 0) revert Errors__ElectionNotFound(electionId);

        uint256[] memory candidateIds = candidateRegistry.getCandidatesForElection(electionId);

        // Find winner
        uint256 winnerCandidateId;
        uint256 winnerCount;
        for (uint256 i = 0; i < candidateIds.length; i++) {
            uint256 count = _electionTally[electionId][candidateIds[i]];
            if (count > winnerCount) {
                winnerCount = count;
                winnerCandidateId = candidateIds[i];
            }
        }

        // Transition states
        electionFactory.startTallying(electionId);
        electionFactory.finalizeElection(electionId);

        emit Events__ElectionFinalized(
            electionId,
            winnerCandidateId,
            winnerCount,
            election.totalVotes,
            uint64(block.timestamp)
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getVoteRecord(address voter, uint256 electionId)
        external
        view
        returns (DataTypes.VoteRecord memory)
    {
        return _votes[voter][electionId];
    }

    function hasVoted(address voter, uint256 electionId) external view returns (bool) {
        return _hasVoted[voter][electionId];
    }

    function getElectionResults(uint256 electionId)
        external
        view
        returns (uint256[] memory candidateIds, uint256[] memory voteCounts)
    {
        candidateIds = candidateRegistry.getCandidatesForElection(electionId);
        voteCounts = new uint256[](candidateIds.length);
        for (uint256 i = 0; i < candidateIds.length; i++) {
            voteCounts[i] = _electionTally[electionId][candidateIds[i]];
        }
    }

    function getWinner(uint256 electionId)
        external
        view
        returns (uint256 candidateId, uint256 voteCount)
    {
        uint256[] memory candidateIds = candidateRegistry.getCandidatesForElection(electionId);
        for (uint256 i = 0; i < candidateIds.length; i++) {
            uint256 count = _electionTally[electionId][candidateIds[i]];
            if (count > voteCount) {
                voteCount = count;
                candidateId = candidateIds[i];
            }
        }
    }

    function getCandidateTally(uint256 electionId, uint256 candidateId)
        external
        view
        returns (uint256)
    {
        return _electionTally[electionId][candidateId];
    }

    function totalVotesCast() external view returns (uint256) { return _totalVotesCast; }

    function domainSeparator() external view returns (bytes32) { return _DOMAIN_SEPARATOR; }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _validateVoteSignature(CastVoteParams calldata params) internal {
        if (block.timestamp > params.deadline) {
            revert Errors__SignatureExpired(params.deadline, uint64(block.timestamp));
        }
        if (_usedNonces[params.voteNonce]) revert Errors__NonceUsed(params.voteNonce);

        bytes32 structHash = keccak256(
            abi.encode(
                _VOTE_TYPEHASH,
                msg.sender,
                params.electionId,
                params.candidateId,
                params.identityHash,
                params.voteNonce,
                params.deadline
            )
        );
        bytes32 digest = _DOMAIN_SEPARATOR.toTypedDataHash(structHash);
        address signer = digest.recover(params.backendSig);

        if (!hasRole(Constants.BACKEND_SIGNER_ROLE, signer)) revert Errors__InvalidSignature();
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    function setContracts(
        address _identityRegistry,
        address _electionFactory,
        address _candidateRegistry,
        address _feeEscrow
    ) external onlyRole(Constants.ADMIN_ROLE) {
        if (_identityRegistry != address(0)) identityRegistry = IIdentityRegistry(_identityRegistry);
        if (_electionFactory != address(0)) electionFactory = IElectionFactory(_electionFactory);
        if (_candidateRegistry != address(0)) candidateRegistry = ICandidateRegistry(_candidateRegistry);
        if (_feeEscrow != address(0)) feeEscrow = IVoteFeeEscrow(_feeEscrow);
    }

    function updateBackendSigner(address oldSigner, address newSigner)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        if (newSigner == address(0)) revert Errors__ZeroAddress();
        _revokeRole(Constants.BACKEND_SIGNER_ROLE, oldSigner);
        _grantRole(Constants.BACKEND_SIGNER_ROLE, newSigner);
    }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
