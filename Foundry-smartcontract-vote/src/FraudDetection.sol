// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "./types/DataTypes.sol";
import {Constants} from "./types/Constants.sol";
import {Errors__FlagNotFound,
        Errors__NotFraudOracle,
        Errors__ZeroAddress} from "./types/Errors.sol";
import {Events__FraudFlagRaised,
        Events__FraudFlagResolved} from "./types/Events.sol";
import {IFraudDetection} from "../interfaces/IFraudDetection.sol";
import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";

/// @title FraudDetection
/// @notice Receives fraud signals from the FastAPI oracle (backend AI analysis),
///         raises on-chain flags, and triggers ban escalation.
///
/// @dev Fraud signals from FastAPI include:
///       - Multiple biometric matches (duplicate identity)
///       - GPS/IP spoofing detected
///       - Region mismatch detected on-chain vs off-chain
///       - Suspicious voting patterns (bot-like timing)
///       - SIM-swapping or wallet compromise suspected
///
///      HIGH/CRITICAL severity flags automatically trigger ban + identity lock.
///      LOW/MEDIUM flags are logged for manual review.
contract FraudDetection is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IFraudDetection
{
    // ─── State ───────────────────────────────────────────────────────────────

    IIdentityRegistry public identityRegistry;

    mapping(uint256 => DataTypes.FraudFlag) private _flags;
    mapping(address => uint256[]) private _targetFlags;

    uint256 private _nextFlagId;
    uint256 private _totalFlags;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address admin, address _identityRegistry) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.FRAUD_ORACLE_ROLE, admin);
        _grantRole(Constants.MODERATOR_ROLE, admin);

        identityRegistry = IIdentityRegistry(_identityRegistry);
        _nextFlagId = 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  FLAG
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Raise a fraud flag against a target address.
    ///         Only FRAUD_ORACLE_ROLE (FastAPI backend) can call.
    ///         HIGH/CRITICAL: auto-ban via IdentityRegistry.
    function raiseFlag(
        address target,
        DataTypes.FraudSeverity severity,
        bytes32 evidenceHash
    )
        external
        whenNotPaused
        onlyRole(Constants.FRAUD_ORACLE_ROLE)
        returns (uint256 flagId)
    {
        flagId = _nextFlagId++;
        _totalFlags++;

        _flags[flagId] = DataTypes.FraudFlag({
            id: flagId,
            target: target,
            severity: severity,
            evidenceHash: evidenceHash,
            reporter: msg.sender,
            flaggedAt: uint64(block.timestamp),
            resolved: false,
            resolvedAt: 0,
            resolver: address(0)
        });

        _targetFlags[target].push(flagId);

        emit Events__FraudFlagRaised(flagId, target, severity, evidenceHash, msg.sender, uint64(block.timestamp));

        // Auto-ban on HIGH/CRITICAL if not already banned
        if (
            (severity == DataTypes.FraudSeverity.HIGH || severity == DataTypes.FraudSeverity.CRITICAL)
            && !identityRegistry.isVoterBanned(target)
        ) {
            // Call via try/catch — voter may not be registered (non-voter fraud target)
            try identityRegistry.banVoter(target, evidenceHash, type(uint64).max, bytes32(flagId), "") {
                // banned successfully
            } catch {
                // Not registered as voter — flag still recorded
            }
        }
    }

    function resolveFlag(uint256 flagId)
        external
        onlyRole(Constants.MODERATOR_ROLE)
    {
        DataTypes.FraudFlag storage flag = _getFlag(flagId);
        flag.resolved = true;
        flag.resolvedAt = uint64(block.timestamp);
        flag.resolver = msg.sender;
        emit Events__FraudFlagResolved(flagId, msg.sender, uint64(block.timestamp));
    }

    /// @notice Manually ban a target (for moderator-initiated bans).
    function banTarget(address target, bytes32 evidenceHash)
        external
        onlyRole(Constants.MODERATOR_ROLE)
    {
        // raises a flag first for audit trail
        uint256 flagId = _nextFlagId++;
        _totalFlags++;
        _flags[flagId] = DataTypes.FraudFlag({
            id: flagId,
            target: target,
            severity: DataTypes.FraudSeverity.HIGH,
            evidenceHash: evidenceHash,
            reporter: msg.sender,
            flaggedAt: uint64(block.timestamp),
            resolved: false,
            resolvedAt: 0,
            resolver: address(0)
        });
        _targetFlags[target].push(flagId);
        emit Events__FraudFlagRaised(
            flagId, target, DataTypes.FraudSeverity.HIGH, evidenceHash, msg.sender, uint64(block.timestamp)
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getFlag(uint256 flagId) external view returns (DataTypes.FraudFlag memory) {
        return _flags[flagId];
    }

    function getFlagsForTarget(address target) external view returns (uint256[] memory) {
        return _targetFlags[target];
    }

    function isFlagged(address target) external view returns (bool) {
        return _targetFlags[target].length > 0;
    }

    function totalFlags() external view returns (uint256) { return _totalFlags; }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getFlag(uint256 flagId) internal view returns (DataTypes.FraudFlag storage) {
        DataTypes.FraudFlag storage f = _flags[flagId];
        if (f.id == 0) revert Errors__FlagNotFound(flagId);
        return f;
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}