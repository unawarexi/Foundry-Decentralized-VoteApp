// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "../types/DataTypes.sol";
import {Constants} from "../types/Constants.sol";
import {Errors__ElectionNotFound,
        Errors__ElectionNotActive,
        Errors__ElectionNotStarted,
        Errors__ElectionEnded,
        Errors__ElectionAlreadyFinalized,
        Errors__ElectionAlreadyCancelled,
        Errors__NotElectionCreator,
        Errors__InvalidElectionWindow,
        Errors__InsufficientCandidates,
        Errors__AlreadyTallied,
        Errors__ZeroAddress,
        Errors__RegionNotActive} from "../types/Errors.sol";
import {Events__ElectionCreated,
        Events__ElectionActivated,
        Events__ElectionPaused,
        Events__ElectionResumed,
        Events__ElectionCancelled,
        Events__ElectionTallyStarted,
        Events__ElectionFinalized} from "../types/Events.sol";
import {IElectionFactory} from "../../interfaces/IElectionFactory.sol";
import {IRegionRegistry} from "../../interfaces/IRegionRegistry.sol";
import {ICandidateRegistry} from "../../interfaces/ICandidateRegistry.sol";

/// @title ElectionFactory
/// @notice Creates, configures, and manages the lifecycle of elections.
///         Each election is region-locked and type-specific.
///
///         Lifecycle: PENDING → ACTIVE → (PAUSED) → TALLYING → FINALIZED
///                                               ↘ CANCELLED
///
/// @dev ElectionFactory stores election metadata.
///      VoteProtocol handles vote casting and tallying.
///      CandidateRegistry handles candidate management.
contract ElectionFactory is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IElectionFactory
{
    // ─── State ───────────────────────────────────────────────────────────────

    /// electionId → Election
    mapping(uint256 => DataTypes.Election) private _elections;

    /// regionHash → electionId[]
    mapping(bytes32 => uint256[]) private _regionElections;

    uint256 private _nextElectionId;
    uint256 private _totalElections;

    IRegionRegistry public regionRegistry;
    ICandidateRegistry public candidateRegistry;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(
        address admin,
        address _regionRegistry,
        address _candidateRegistry
    ) external initializer {
        if (admin == address(0) || _regionRegistry == address(0) || _candidateRegistry == address(0)) {
            revert Errors__ZeroAddress();
        }
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.ELECTION_CREATOR_ROLE, admin);
        _grantRole(Constants.TALLY_ROLE, admin);

        regionRegistry = IRegionRegistry(_regionRegistry);
        candidateRegistry = ICandidateRegistry(_candidateRegistry);

        _nextElectionId = 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  CREATE
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Create a new election for a specific region.
    function createElection(
        bytes32 regionHash,
        DataTypes.ElectionType electionType,
        uint64 startTime,
        uint64 endTime,
        uint256 voteFeeUSD,
        DataTypes.PaymentToken acceptedToken,
        bool requireBiometric,
        bool allowRevote,
        uint8 minVerificationLevel
    )
        external
        whenNotPaused
        onlyRole(Constants.ELECTION_CREATOR_ROLE)
        returns (uint256 electionId)
    {
        if (!regionRegistry.isRegionActive(regionHash)) revert Errors__RegionNotActive(regionHash);
        if (startTime >= endTime) revert Errors__InvalidElectionWindow(startTime, endTime);
        if (endTime - startTime < Constants.MIN_ELECTION_DURATION) {
            revert Errors__InvalidElectionWindow(startTime, endTime);
        }
        if (endTime - startTime > Constants.MAX_ELECTION_DURATION) {
            revert Errors__InvalidElectionWindow(startTime, endTime);
        }

        electionId = _nextElectionId++;
        _totalElections++;

        _elections[electionId] = DataTypes.Election({
            id: electionId,
            regionHash: regionHash,
            electionType: electionType,
            status: DataTypes.ElectionStatus.PENDING,
            startTime: startTime,
            endTime: endTime,
            finalizedAt: 0,
            totalVotes: 0,
            voteFeeUSD: voteFeeUSD,
            acceptedToken: acceptedToken,
            creator: msg.sender,
            candidates: new address[](0),
            requireBiometric: requireBiometric,
            allowRevote: allowRevote,
            minVerificationLevel: minVerificationLevel
        });

        _regionElections[regionHash].push(electionId);
        regionRegistry.incrementElectionCount(regionHash);

        emit Events__ElectionCreated(
            electionId, regionHash, electionType, msg.sender, startTime, endTime
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  LIFECYCLE TRANSITIONS
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Activate an election (must have enough verified candidates).
    function activateElection(uint256 electionId)
        external
        onlyRole(Constants.ELECTION_CREATOR_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        _requireStatus(e, DataTypes.ElectionStatus.PENDING);

        uint256[] memory candidateIds = candidateRegistry.getCandidatesForElection(electionId);
        if (candidateIds.length < Constants.MIN_CANDIDATES_PER_ELECTION) {
            revert Errors__InsufficientCandidates(
                electionId,
                candidateIds.length,
                Constants.MIN_CANDIDATES_PER_ELECTION
            );
        }

        e.status = DataTypes.ElectionStatus.ACTIVE;
        emit Events__ElectionActivated(electionId, uint64(block.timestamp));
    }

    function pauseElection(uint256 electionId, string calldata reason)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        _requireStatus(e, DataTypes.ElectionStatus.ACTIVE);
        e.status = DataTypes.ElectionStatus.PAUSED;
        emit Events__ElectionPaused(electionId, msg.sender, reason);
    }

    function resumeElection(uint256 electionId)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        _requireStatus(e, DataTypes.ElectionStatus.PAUSED);
        e.status = DataTypes.ElectionStatus.ACTIVE;
        emit Events__ElectionResumed(electionId, msg.sender);
    }

    function cancelElection(uint256 electionId, string calldata reason)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        if (e.status == DataTypes.ElectionStatus.FINALIZED) {
            revert Errors__ElectionAlreadyFinalized(electionId);
        }
        if (e.status == DataTypes.ElectionStatus.CANCELLED) {
            revert Errors__ElectionAlreadyCancelled(electionId);
        }
        e.status = DataTypes.ElectionStatus.CANCELLED;
        regionRegistry.decrementElectionCount(e.regionHash);
        emit Events__ElectionCancelled(electionId, msg.sender, reason);
    }

    /// @notice Transition to TALLYING — called after voting window closes.
    ///         Can be called by TALLY_ROLE or automatically by VoteProtocol.
    function startTallying(uint256 electionId)
        external
        onlyRole(Constants.TALLY_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        if (e.status != DataTypes.ElectionStatus.ACTIVE &&
            e.status != DataTypes.ElectionStatus.PAUSED) {
            revert Errors__ElectionNotActive(electionId);
        }
        if (block.timestamp < e.endTime) {
            revert Errors__ElectionNotStarted(electionId, e.endTime);
        }
        e.status = DataTypes.ElectionStatus.TALLYING;
        emit Events__ElectionTallyStarted(electionId, uint64(block.timestamp));
    }

    /// @notice Finalize election with winner data. Called by VoteProtocol after tally.
    function finalizeElection(uint256 electionId)
        external
        onlyRole(Constants.TALLY_ROLE)
    {
        DataTypes.Election storage e = _getElection(electionId);
        _requireStatus(e, DataTypes.ElectionStatus.TALLYING);
        e.status = DataTypes.ElectionStatus.FINALIZED;
        e.finalizedAt = uint64(block.timestamp);
        regionRegistry.decrementElectionCount(e.regionHash);
    }

    /// @notice Called by VoteProtocol to increment the vote counter.
    function incrementVoteCount(uint256 electionId)
        external
        onlyRole(Constants.OPERATOR_ROLE)
    {
        _elections[electionId].totalVotes++;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getElection(uint256 electionId)
        external
        view
        returns (DataTypes.Election memory)
    {
        return _elections[electionId];
    }

    function isElectionActive(uint256 electionId) external view returns (bool) {
        DataTypes.Election storage e = _elections[electionId];
        return e.status == DataTypes.ElectionStatus.ACTIVE
            && block.timestamp >= e.startTime
            && block.timestamp <= e.endTime;
    }

    function totalElections() external view returns (uint256) {
        return _totalElections;
    }

    function getElectionsByRegion(bytes32 regionHash)
        external
        view
        returns (uint256[] memory)
    {
        return _regionElections[regionHash];
    }

    function getElectionStatus(uint256 electionId)
        external
        view
        returns (DataTypes.ElectionStatus)
    {
        return _elections[electionId].status;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getElection(uint256 electionId)
        internal
        view
        returns (DataTypes.Election storage)
    {
        DataTypes.Election storage e = _elections[electionId];
        if (e.id == 0) revert Errors__ElectionNotFound(electionId);
        return e;
    }

    function _requireStatus(
        DataTypes.Election storage e,
        DataTypes.ElectionStatus expected
    ) internal view {
        if (e.status != expected) revert Errors__ElectionNotActive(e.id);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    function setRegistries(address _regionRegistry, address _candidateRegistry)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        if (_regionRegistry != address(0)) regionRegistry = IRegionRegistry(_regionRegistry);
        if (_candidateRegistry != address(0)) candidateRegistry = ICandidateRegistry(_candidateRegistry);
    }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
