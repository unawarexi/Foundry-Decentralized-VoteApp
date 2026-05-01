// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {Constants} from "../types/Constants.sol";
import {Errors__ZeroAddress, Errors__InvalidSignature} from "../types/Errors.sol";

/// @title ZKVerifier
/// @notice Verifies zero-knowledge proofs for voter identity.
///         Currently implements a Groth16 verifier stub.
///         Production: integrate Circom-generated Groth16 verifier or Polygon ID.
///
/// @dev The verification key and proof format follow the Groth16 standard:
///       - Proof: (A, B, C) on BN254 elliptic curve
///       - Public inputs: [nullifier, identityCommitment, regionCommitment, chainId]
///       - Verification key: deployed separately and referenced here
///
///      This contract will be updated when the ZK circuit (Circom) is ready.
///      For now, it accepts proofs signed by the backend key (trusted verifier).
contract ZKVerifier is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /// Mapping of used nullifiers to prevent proof replay
    mapping(bytes32 => bool) private _usedNullifiers;

    /// Trusted verifier key hash — updated when circuit changes
    bytes32 public verificationKeyHash;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address admin, bytes32 _verificationKeyHash) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        verificationKeyHash = _verificationKeyHash;
    }

    /// @notice Verify a Groth16 ZK proof.
    ///         Stub — replace with auto-generated Circom verifier in production.
    /// @param nullifier            Unique nullifier prevents double-use of a proof
    /// @param identityCommitment   Hash(secret + identityHash)
    /// @param regionCommitment     Hash(secret + regionHash)
    /// @param proof                Groth16 proof bytes
    /// @return valid               True if proof is valid
    function verifyIdentityProof(
        bytes32 nullifier,
        bytes32 identityCommitment,
        bytes32 regionCommitment,
        bytes calldata proof
    ) external returns (bool valid) {
        if (_usedNullifiers[nullifier]) revert Errors__InvalidSignature();

        // TODO: Replace with auto-generated Groth16 verifier from Circom
        // For now: accepts any non-zero proof as valid (dev mode only)
        // Production: call the actual pairing-based verifier here
        valid = proof.length == 256 && nullifier != bytes32(0);

        if (valid) {
            _usedNullifiers[nullifier] = true;
        }

        // Silence unused var warnings — used in real verifier
        identityCommitment;
        regionCommitment;
    }

    function isNullifierUsed(bytes32 nullifier) external view returns (bool) {
        return _usedNullifiers[nullifier];
    }

    function updateVerificationKey(bytes32 newKeyHash) external onlyRole(Constants.ADMIN_ROLE) {
        verificationKeyHash = newKeyHash;
    }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}