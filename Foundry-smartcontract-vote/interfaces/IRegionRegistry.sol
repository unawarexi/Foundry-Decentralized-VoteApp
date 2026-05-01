// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IRegionRegistry {
    function registerRegion(string calldata countryISO, string calldata regionCode) external returns (bytes32);
    function deactivateRegion(bytes32 regionId) external;
    function activateRegion(bytes32 regionId) external;
    function incrementVoterCount(bytes32 regionId) external;
    function incrementElectionCount(bytes32 regionId) external;
    function decrementElectionCount(bytes32 regionId) external;

    function getRegion(bytes32 regionId) external view returns (DataTypes.Region memory);
    function isRegionActive(bytes32 regionId) external view returns (bool);
    function regionExists(bytes32 regionId) external view returns (bool);
    function computeRegionId(string calldata countryISO, string calldata regionCode) external pure returns (bytes32);
    function getAllRegions() external view returns (bytes32[] memory);
    function totalRegions() external view returns (uint256);
}
