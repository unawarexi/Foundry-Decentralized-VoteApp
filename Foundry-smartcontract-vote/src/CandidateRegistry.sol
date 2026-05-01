// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "./types/DataTypes.sol";
import {Constants} from "./types/Constants.sol";
import {Errors__CandidateNotFound,
        Errors__CandidateNotActive,
        Errors__CandidateAlreadyRegistered,
        Errors__MissingCandidateProfile,
        Errors__ZeroAddress,
        Errors__OutOfBounds} from "./types/Errors.sol";
import {Events__CandidateRegistered,
        Events__CandidateVerified,
        Events__CandidateDisqualified,
        Events__CandidateWithdrawn,
        Events__CandidatePopularityUpdated,
        Events__ManifestoUpdated} from "./types/Events.sol";
import {ICandidateRegistry} from "../interfaces/ICandidateRegistry.sol";

/// @title CandidateRegistry
/// @notice Manages candidate registration, identity verification status,
///         manifesto IPFS hashes, and popularity scoring per election.
///
/// @dev Candidate profile data lives on IPFS — only the CID hash is stored on-chain.
///      Popularity score is updated by the backend oracle after AI analysis of
///      forum Q&A responses, sentiment, and SLA compliance.
///
///      Access:
///        - ELECTION_CREATOR_ROLE: register candidates
///        - OPERATOR_ROLE: verify candidates, update scores, increment vote counts
///        - MODERATOR_ROLE: disqualify candidates
///        - Candidate wallet: withdraw themselves
contract CandidateRegistry is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    ICandidateRegistry
{
    // ─── State ───────────────────────────────────────────────────────────────

    /// candidateId → Candidate
    mapping(uint256 => DataTypes.Candidate) private _candidates;

    /// electionId → candidateId[]
    mapping(uint256 => uint256[]) private _electionCandidates;

    /// electionId → wallet → candidateId (prevent duplicate registration)
    mapping(uint256 => mapping(address => uint256)) private _electionWalletToCandidateId;

    uint256 private _nextCandidateId;
    uint256 private _totalCandidates;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address admin) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        __Pausable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.MODERATOR_ROLE, admin);
        _nextCandidateId = 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  REGISTRATION
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Register a candidate for an election.
    ///         Called by ElectionFactory (which has ELECTION_CREATOR_ROLE).
    function registerCandidate(
        uint256 electionId,
        address wallet,
        bytes32 profileIpfsHash,
        bytes32 manifestoIpfsHash,
        bytes32 partyId
    )
        external
        whenNotPaused
        onlyRole(Constants.ELECTION_CREATOR_ROLE)
        returns (uint256 candidateId)
    {
        if (profileIpfsHash == bytes32(0)) revert Errors__MissingCandidateProfile();
        if (_electionWalletToCandidateId[electionId][wallet] != 0) {
            revert Errors__CandidateAlreadyRegistered(wallet, electionId);
        }
        if (_electionCandidates[electionId].length >= Constants.MAX_CANDIDATES_PER_ELECTION) {
            revert Errors__OutOfBounds(
                _electionCandidates[electionId].length,
                0,
                Constants.MAX_CANDIDATES_PER_ELECTION
            );
        }

        candidateId = _nextCandidateId++;
        _totalCandidates++;

        _candidates[candidateId] = DataTypes.Candidate({
            id: candidateId,
            electionId: electionId,
            wallet: wallet,
            profileIpfsHash: profileIpfsHash,
            manifestoIpfsHash: manifestoIpfsHash,
            status: DataTypes.CandidateStatus.PENDING,
            voteCount: 0,
            popularityScore: Constants.INITIAL_POPULARITY_SCORE,
            registeredAt: uint64(block.timestamp),
            partyId: partyId,
            identityVerified: false
        });

        _electionCandidates[electionId].push(candidateId);
        _electionWalletToCandidateId[electionId][wallet] = candidateId;

        emit Events__CandidateRegistered(candidateId, electionId, wallet, partyId, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  STATUS TRANSITIONS
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Mark a candidate as identity-verified and activate them.
    ///         Called by backend oracle after off-chain ID verification.
    function verifyCandidate(uint256 candidateId)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        c.identityVerified = true;
        c.status = DataTypes.CandidateStatus.ACTIVE;
        emit Events__CandidateVerified(candidateId, uint64(block.timestamp));
    }

    function disqualifyCandidate(uint256 candidateId, bytes32 reason)
        external
        onlyRole(Constants.MODERATOR_ROLE)
    {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        c.status = DataTypes.CandidateStatus.DISQUALIFIED;
        emit Events__CandidateDisqualified(candidateId, msg.sender, reason, uint64(block.timestamp));
    }

    /// @notice Candidate may withdraw themselves before election goes ACTIVE.
    function withdrawCandidate(uint256 candidateId) external whenNotPaused {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        require(c.wallet == msg.sender || hasRole(Constants.ADMIN_ROLE, msg.sender), "Not authorized");
        c.status = DataTypes.CandidateStatus.WITHDRAWN;
        emit Events__CandidateWithdrawn(candidateId, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  UPDATES
    // ─────────────────────────────────────────────────────────────────────────

    function updateManifesto(uint256 candidateId, bytes32 newIpfsHash)
        external
        whenNotPaused
    {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        require(
            c.wallet == msg.sender || hasRole(Constants.ADMIN_ROLE, msg.sender),
            "Not authorized"
        );
        c.manifestoIpfsHash = newIpfsHash;
        emit Events__ManifestoUpdated(candidateId, newIpfsHash, uint64(block.timestamp));
    }

    /// @notice Update popularity score from oracle/backend.
    function updatePopularityScore(uint256 candidateId, uint256 newScore)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        if (newScore > Constants.MAX_POPULARITY_SCORE) {
            newScore = Constants.MAX_POPULARITY_SCORE;
        }
        uint256 old = c.popularityScore;
        c.popularityScore = newScore;
        emit Events__CandidatePopularityUpdated(candidateId, old, newScore);
    }

    /// @notice Apply a signed popularity delta (can be negative — from forum SLA misses).
    function applyPopularityDelta(uint256 candidateId, int256 delta)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.Candidate storage c = _getCandidate(candidateId);
        uint256 old = c.popularityScore;
        int256 newScore = int256(c.popularityScore) + delta;
        if (newScore < 0) newScore = 0;
        if (newScore > int256(Constants.MAX_POPULARITY_SCORE)) {
            newScore = int256(Constants.MAX_POPULARITY_SCORE);
        }
        c.popularityScore = uint256(newScore);
        emit Events__CandidatePopularityUpdated(candidateId, old, c.popularityScore);
    }

    /// @notice Increment vote count — called by VoteProtocol after a successful vote.
    function incrementVoteCount(uint256 candidateId)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        _getCandidate(candidateId).voteCount++;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getCandidate(uint256 candidateId)
        external
        view
        returns (DataTypes.Candidate memory)
    {
        return _candidates[candidateId];
    }

    function getCandidatesForElection(uint256 electionId)
        external
        view
        returns (uint256[] memory)
    {
        return _electionCandidates[electionId];
    }

    function isCandidateActive(uint256 candidateId) external view returns (bool) {
        return _candidates[candidateId].status == DataTypes.CandidateStatus.ACTIVE;
    }

    function getCandidateWallet(uint256 electionId, address wallet) external view returns (uint256) {
        return _electionWalletToCandidateId[electionId][wallet];
    }

    function totalCandidates() external view returns (uint256) {
        return _totalCandidates;
    }

    /// @notice Get election candidates with full data — used by frontend.
    function getCandidateDetails(uint256 electionId)
        external
        view
        returns (DataTypes.Candidate[] memory candidates)
    {
        uint256[] storage ids = _electionCandidates[electionId];
        candidates = new DataTypes.Candidate[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            candidates[i] = _candidates[ids[i]];
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getCandidate(uint256 candidateId) internal view returns (DataTypes.Candidate storage) {
        DataTypes.Candidate storage c = _candidates[candidateId];
        if (c.id == 0) revert Errors__CandidateNotFound(candidateId);
        return c;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
