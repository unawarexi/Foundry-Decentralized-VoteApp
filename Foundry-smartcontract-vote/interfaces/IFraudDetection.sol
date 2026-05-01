// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IFraudDetection {
    function raiseFlag(
        address target,
        DataTypes.FraudSeverity severity,
        bytes32 evidenceHash
    ) external returns (uint256 flagId);

    function resolveFlag(uint256 flagId) external;
    function banTarget(address target, bytes32 evidenceHash) external;

    function getFlag(uint256 flagId) external view returns (DataTypes.FraudFlag memory);
    function getFlagsForTarget(address target) external view returns (uint256[] memory);
    function isFlagged(address target) external view returns (bool);
    function totalFlags() external view returns (uint256);
}