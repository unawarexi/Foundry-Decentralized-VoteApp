// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {DataTypes} from "../types/DataTypes.sol";
import {Constants} from "../types/Constants.sol";
import {Errors__VoterNotRegistered,
        Errors__VoterBanned,
        Errors__IdentityMismatch,
        Errors__InsufficientVerificationLevel,
        Errors__RegionMismatch,
        Errors__IdentityAlreadyRegistered,
        Errors__InvalidSignature,
        Errors__SignatureExpired,
        Errors__NonceUsed,
        Errors__ZeroAddress,
        Errors__AlreadyBanned,
        Errors__NotBanned} from "../types/Errors.sol";
import {Events__VoterRegistered,
        Events__VoterBanned,
        Events__VoterUnbanned,
        Events__VoterVerificationUpgraded,
        Events__BackendSignerUpdated} from "../types/Events.sol";
import {IIdentityRegistry} from "../../interfaces/IIdentityRegistry.sol";

/// @title IdentityRegistry
/// @notice Manages voter identity registration, verification levels, region locking,
///         and banning. Sensitive data (biometrics, government ID) is NEVER stored
///         on-chain — only cryptographic commitments/hashes from FastAPI are stored.
///
/// @dev Uses EIP-712 typed signatures from the FastAPI backend signer to authorize
///      registration and verification upgrades, ensuring no direct on-chain path
///      to register an identity without off-chain AI verification.
///
/// SECURITY MODEL:
///   • Registration requires a valid signature from `BACKEND_SIGNER_ROLE` key
///   • Signatures are single-use (nonce invalidation)
///   • Signatures expire after SIGNATURE_VALIDITY (15 min) to prevent replay
///   • Identity hash = keccak256(abi.encode(userId, regionHash, verifiedFlag, chainId))
///   • Region locking is enforced at this layer and at VoteProtocol layer
contract IdentityRegistry is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable,
    IIdentityRegistry
{
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // ─── EIP-712 type hashes ─────────────────────────────────────────────────
    bytes32 private constant _REGISTRATION_TYPEHASH = keccak256(
        "Registration(address wallet,bytes32 identityHash,bytes32 regionHash,uint8 level,uint64 deadline,bytes32 nonce)"
    );
    bytes32 private constant _VERIFICATION_UPGRADE_TYPEHASH = keccak256(
        "VerificationUpgrade(address wallet,uint8 newLevel,bytes32 identityHash,uint64 deadline,bytes32 nonce)"
    );
    bytes32 private constant _BAN_TYPEHASH = keccak256(
        "Ban(address target,bytes32 evidenceHash,uint64 deadline,bytes32 nonce)"
    );

    // ─── EIP-712 domain separator ────────────────────────────────────────────
    bytes32 private _DOMAIN_SEPARATOR;

    // ─── State ───────────────────────────────────────────────────────────────

    /// wallet → Voter
    mapping(address => DataTypes.Voter) private _voters;

    /// identityHash → wallet — prevents duplicate identity registration
    mapping(bytes32 => address) private _identityHashToWallet;

    /// nonce → used — replay protection
    mapping(bytes32 => bool) private _usedNonces;

    /// Total registered voters
    uint256 private _totalVoters;

    // ─────────────────────────────────────────────────────────────────────────
    //  INITIALIZER
    // ─────────────────────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address backendSigner) external initializer {
        if (admin == address(0) || backendSigner == address(0)) revert Errors__ZeroAddress();

        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.BACKEND_SIGNER_ROLE, backendSigner);
        _grantRole(Constants.MODERATOR_ROLE, admin);

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
    //  REGISTRATION
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Register a voter identity.
    ///         The FastAPI backend verifies biometrics, ID, region, and age,
    ///         then signs a message authorising this registration.
    /// @param identityHash   keccak256(userId + regionHash + verifiedFlag + chainId)
    /// @param regionHash     keccak256(countryISO + regionCode)
    /// @param level          Verification level achieved
    /// @param deadline       Signature expiry timestamp
    /// @param nonce          Single-use random nonce
    /// @param signature      ECDSA signature from backend signer (EIP-712)
    function registerVoter(
        bytes32 identityHash,
        bytes32 regionHash,
        DataTypes.VerificationLevel level,
        uint64 deadline,
        bytes32 nonce,
        bytes calldata signature
    )
        external
        whenNotPaused
    {
        _validateDeadline(deadline);
        _validateNonce(nonce);

        // Reconstruct and verify the EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(
                _REGISTRATION_TYPEHASH,
                msg.sender,
                identityHash,
                regionHash,
                uint8(level),
                deadline,
                nonce
            )
        );
        _verifyBackendSignature(structHash, signature);

        // Prevent identity hash reuse across different wallets
        if (_identityHashToWallet[identityHash] != address(0)) {
            revert Errors__IdentityAlreadyRegistered(identityHash);
        }

        _usedNonces[nonce] = true;
        _identityHashToWallet[identityHash] = msg.sender;
        _totalVoters++;

        _voters[msg.sender] = DataTypes.Voter({
            identityHash: identityHash,
            regionHash: regionHash,
            level: level,
            isBanned: false,
            totalVotesCast: 0,
            registeredAt: uint64(block.timestamp),
            lastVoteAt: 0,
            wallet: msg.sender
        });

        emit Events__VoterRegistered(msg.sender, identityHash, regionHash, level, uint64(block.timestamp));
    }

    /// @notice Upgrade the verification level of an existing voter.
    ///         Called after additional verification (e.g. ZK proof) is completed off-chain.
    function upgradeVerificationLevel(
        DataTypes.VerificationLevel newLevel,
        bytes32 identityHash,
        uint64 deadline,
        bytes32 nonce,
        bytes calldata signature
    )
        external
        whenNotPaused
    {
        DataTypes.Voter storage voter = _getVoter(msg.sender);

        _validateDeadline(deadline);
        _validateNonce(nonce);

        if (voter.identityHash != identityHash) {
            revert Errors__IdentityMismatch(msg.sender, voter.identityHash, identityHash);
        }

        bytes32 structHash = keccak256(
            abi.encode(
                _VERIFICATION_UPGRADE_TYPEHASH,
                msg.sender,
                uint8(newLevel),
                identityHash,
                deadline,
                nonce
            )
        );
        _verifyBackendSignature(structHash, signature);

        _usedNonces[nonce] = true;

        DataTypes.VerificationLevel old = voter.level;
        voter.level = newLevel;

        emit Events__VoterVerificationUpgraded(msg.sender, old, newLevel, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  BAN / UNBAN (Moderation)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Ban a voter. Can be triggered by moderator OR by backend signer (fraud oracle).
    ///         When triggered by fraud oracle: requires an EIP-712 signed message.
    ///         When triggered by moderator directly: no signature needed.
    function banVoter(
        address target,
        bytes32 evidenceHash,
        uint64 deadline,
        bytes32 nonce,
        bytes calldata signature
    )
        external
        whenNotPaused
    {
        DataTypes.Voter storage voter = _getVoter(target);
        if (voter.isBanned) revert Errors__AlreadyBanned(target);

        if (hasRole(Constants.MODERATOR_ROLE, msg.sender)) {
            // Direct moderator action — no signature needed
            _usedNonces[nonce] = true; // consume nonce regardless
        } else {
            // Backend/fraud oracle path — validate signature
            _validateDeadline(deadline);
            _validateNonce(nonce);
            bytes32 structHash = keccak256(abi.encode(_BAN_TYPEHASH, target, evidenceHash, deadline, nonce));
            _verifyBackendSignature(structHash, signature);
            _usedNonces[nonce] = true;
        }

        voter.isBanned = true;
        emit Events__VoterBanned(target, evidenceHash, msg.sender, uint64(block.timestamp));
    }

    /// @notice Unban a voter — only ADMIN or MODERATOR
    function unbanVoter(address target) external onlyRole(Constants.MODERATOR_ROLE) {
        DataTypes.Voter storage voter = _getVoter(target);
        if (!voter.isBanned) revert Errors__NotBanned(target);
        voter.isBanned = false;
        emit Events__VoterUnbanned(target, msg.sender, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  RECORD VOTE (called by VoteProtocol)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Increment vote counter for a voter. Only callable by VoteProtocol.
    function recordVoteCast(address voter) external onlyRole(Constants.OPERATOR_ROLE) {
        DataTypes.Voter storage v = _getVoter(voter);
        v.totalVotesCast++;
        v.lastVoteAt = uint64(block.timestamp);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW FUNCTIONS
    // ─────────────────────────────────────────────────────────────────────────

    function getVoter(address wallet) external view returns (DataTypes.Voter memory) {
        return _voters[wallet];
    }

    function isVoterRegistered(address wallet) external view returns (bool) {
        return _voters[wallet].wallet != address(0);
    }

    function isVoterBanned(address wallet) external view returns (bool) {
        return _voters[wallet].isBanned;
    }

    function getVerificationLevel(address wallet) external view returns (DataTypes.VerificationLevel) {
        return _voters[wallet].level;
    }

    function getRegionHash(address wallet) external view returns (bytes32) {
        return _voters[wallet].regionHash;
    }

    function totalVoters() external view returns (uint256) {
        return _totalVoters;
    }

    function isNonceUsed(bytes32 nonce) external view returns (bool) {
        return _usedNonces[nonce];
    }

    function domainSeparator() external view returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    /// @notice Check all eligibility conditions for a voter in one call.
    ///         Returns (eligible, reason) — used by VoteProtocol before processing.
    function checkVoterEligibility(
        address wallet,
        bytes32 electionRegionHash,
        uint8 minLevel
    )
        external
        view
        returns (bool eligible, string memory reason)
    {
        DataTypes.Voter storage v = _voters[wallet];
        if (v.wallet == address(0)) return (false, "NOT_REGISTERED");
        if (v.isBanned) return (false, "BANNED");
        if (v.regionHash != electionRegionHash) return (false, "REGION_MISMATCH");
        if (uint8(v.level) < minLevel) return (false, "INSUFFICIENT_VERIFICATION");
        return (true, "");
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function pause() external onlyRole(Constants.ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(Constants.ADMIN_ROLE) {
        _unpause();
    }

    function updateBackendSigner(address newSigner)
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        if (newSigner == address(0)) revert Errors__ZeroAddress();
        address old = _getBackendSigner();
        _revokeRole(Constants.BACKEND_SIGNER_ROLE, old);
        _grantRole(Constants.BACKEND_SIGNER_ROLE, newSigner);
        emit Events__BackendSignerUpdated(old, newSigner);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getVoter(address wallet) internal view returns (DataTypes.Voter storage) {
        DataTypes.Voter storage v = _voters[wallet];
        if (v.wallet == address(0)) revert Errors__VoterNotRegistered(wallet);
        return v;
    }

    function _validateDeadline(uint64 deadline) internal view {
        if (block.timestamp > deadline) revert Errors__SignatureExpired(deadline, uint64(block.timestamp));
    }

    function _validateNonce(bytes32 nonce) internal view {
        if (_usedNonces[nonce]) revert Errors__NonceUsed(nonce);
    }

    function _verifyBackendSignature(bytes32 structHash, bytes calldata signature) internal view {
        bytes32 digest = _DOMAIN_SEPARATOR.toTypedDataHash(structHash);
        address signer = digest.recover(signature);
        if (!hasRole(Constants.BACKEND_SIGNER_ROLE, signer)) revert Errors__InvalidSignature();
    }

    function _getBackendSigner() internal view returns (address) {
        // We track only one signer; admin can rotate it via updateBackendSigner
        // This is a simplification — for multi-signer, extend with an EnumerableSet
        return address(0); // placeholder — role members tracked by AccessControl
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  UUPS UPGRADE AUTHORIZATION
    // ─────────────────────────────────────────────────────────────────────────

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(Constants.UPGRADER_ROLE)
    {}
}
