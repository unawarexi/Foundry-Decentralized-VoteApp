// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IIdentityRegistry {
    function registerVoter(
        bytes32 identityHash,
        bytes32 regionHash,
        DataTypes.VerificationLevel level,
        uint64 deadline,
        bytes32 nonce,
        bytes calldata signature
    ) external;

    function upgradeVerificationLevel(
        DataTypes.VerificationLevel newLevel,
        bytes32 identityHash,
        uint64 deadline,
        bytes32 nonce,
        bytes calldata signature
    ) external;

    function banVoter(address target, bytes32 evidenceHash, uint64 deadline, bytes32 nonce, bytes calldata signature) external;
    function unbanVoter(address target) external;
    function recordVoteCast(address voter) external;

    function getVoter(address wallet) external view returns (DataTypes.Voter memory);
    function isVoterRegistered(address wallet) external view returns (bool);
    function isVoterBanned(address wallet) external view returns (bool);
    function getVerificationLevel(address wallet) external view returns (DataTypes.VerificationLevel);
    function getRegionHash(address wallet) external view returns (bytes32);
    function totalVoters() external view returns (uint256);
    function isNonceUsed(bytes32 nonce) external view returns (bool);
    function checkVoterEligibility(address wallet, bytes32 electionRegionHash, uint8 minLevel)
        external view returns (bool eligible, string memory reason);
}
