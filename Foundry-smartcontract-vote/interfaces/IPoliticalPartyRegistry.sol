// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IPoliticalPartyRegistry {
    function registerParty(string calldata name, bytes32 regionHash, bytes32 logoIpfsHash) external returns (bytes32);
    function deactivateParty(bytes32 partyId) external;
    function updateManifesto(bytes32 partyId, bytes32 manifestoIpfsHash) external;
    function addMember(bytes32 partyId, address member) external;
    function removeMember(bytes32 partyId, address member) external;

    function getParty(bytes32 partyId) external view returns (DataTypes.Party memory);
    function isPartyActive(bytes32 partyId) external view returns (bool);
    function isMember(bytes32 partyId, address member) external view returns (bool);
    function partyExists(bytes32 partyId) external view returns (bool);
    function getAllParties() external view returns (bytes32[] memory);
    function totalParties() external view returns (uint256);
}