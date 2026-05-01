// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "./types/DataTypes.sol";
import {Constants} from "./types/Constants.sol";
import {Errors__ZeroAddress} from "./types/Errors.sol";
import {Events__PartyRegistered,
        Events__PartyDeactivated,
        Events__PartyMemberAdded,
        Events__PartyMemberRemoved} from "./types/Events.sol";
import {IPoliticalPartyRegistry} from "../interfaces/IPoliticalPartyRegistry.sol";

/// @title PoliticalPartyRegistry
/// @notice Manages political party registration and membership.
///         Party ID = keccak256(abi.encode(name, regionHash, registrar)).
contract PoliticalPartyRegistry is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IPoliticalPartyRegistry
{
    mapping(bytes32 => DataTypes.Party) private _parties;
    mapping(bytes32 => mapping(address => bool)) private _members;
    bytes32[] private _partyList;
    uint256 private _totalParties;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(address admin) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
    }

    function registerParty(
        string calldata name,
        bytes32 regionHash,
        bytes32 logoIpfsHash
    ) external onlyRole(Constants.ADMIN_ROLE) returns (bytes32 partyId) {
        partyId = keccak256(abi.encode(name, regionHash, msg.sender));
        require(_parties[partyId].id == bytes32(0), "Party already registered");
        _parties[partyId] = DataTypes.Party({
            id: partyId,
            name: name,
            regionHash: regionHash,
            logoIpfsHash: logoIpfsHash,
            manifestoIpfsHash: bytes32(0),
            memberCount: 0,
            isActive: true,
            registeredAt: uint64(block.timestamp),
            registrar: msg.sender
        });
        _partyList.push(partyId);
        _totalParties++;
        emit Events__PartyRegistered(partyId, name, regionHash, msg.sender);
    }

    function deactivateParty(bytes32 partyId) external onlyRole(Constants.ADMIN_ROLE) {
        require(_parties[partyId].id != bytes32(0), "Party not found");
        _parties[partyId].isActive = false;
        emit Events__PartyDeactivated(partyId, msg.sender);
    }

    function updateManifesto(bytes32 partyId, bytes32 manifestoIpfsHash) external onlyRole(Constants.ADMIN_ROLE) {
        require(_parties[partyId].id != bytes32(0), "Party not found");
        _parties[partyId].manifestoIpfsHash = manifestoIpfsHash;
    }

    function addMember(bytes32 partyId, address member) external onlyRole(Constants.ADMIN_ROLE) {
        require(_parties[partyId].id != bytes32(0), "Party not found");
        require(!_members[partyId][member], "Already a member");
        _members[partyId][member] = true;
        _parties[partyId].memberCount++;
        emit Events__PartyMemberAdded(partyId, member);
    }

    function removeMember(bytes32 partyId, address member) external onlyRole(Constants.ADMIN_ROLE) {
        require(_parties[partyId].id != bytes32(0), "Party not found");
        require(_members[partyId][member], "Not a member");
        _members[partyId][member] = false;
        if (_parties[partyId].memberCount > 0) _parties[partyId].memberCount--;
        emit Events__PartyMemberRemoved(partyId, member);
    }

    function getParty(bytes32 partyId) external view returns (DataTypes.Party memory) { return _parties[partyId]; }
    function isPartyActive(bytes32 partyId) external view returns (bool) { return _parties[partyId].isActive; }
    function isMember(bytes32 partyId, address member) external view returns (bool) { return _members[partyId][member]; }
    function partyExists(bytes32 partyId) external view returns (bool) { return _parties[partyId].id != bytes32(0); }
    function getAllParties() external view returns (bytes32[] memory) { return _partyList; }
    function totalParties() external view returns (uint256) { return _totalParties; }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}