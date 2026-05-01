// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {DataTypes} from "../types/DataTypes.sol";
import {Constants} from "../types/Constants.sol";
import {Errors__ZeroAddress, Errors__RegionNotActive, Errors__OutOfBounds} from "../types/Errors.sol";
import {Events__RegionRegistered, Events__RegionDeactivated} from "../types/Events.sol";
import {IRegionRegistry} from "../../interfaces/IRegionRegistry.sol";

/// @title RegionRegistry
/// @notice Maintains the global registry of all supported geographic regions.
///         Regions are identified by keccak256(abi.encode(countryISO, regionCode)).
///         Elections are bound to a region — voters must match to participate.
///         Only ADMIN can register/deactivate regions.
contract RegionRegistry is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    IRegionRegistry
{
    // ─── State ───────────────────────────────────────────────────────────────

    /// regionHash → Region
    mapping(bytes32 => DataTypes.Region) private _regions;

    /// All known region hashes (for enumeration)
    bytes32[] private _regionList;

    uint256 private _totalRegions;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin) external initializer {
        if (admin == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  WRITE
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Register a new geographic region.
    /// @param countryISO  ISO 3166-1 alpha-2 (e.g. "NG", "US", "GB")
    /// @param regionCode  State/province/district code
    function registerRegion(string calldata countryISO, string calldata regionCode)
        external
        onlyRole(Constants.ADMIN_ROLE)
        returns (bytes32 regionId)
    {
        regionId = keccak256(abi.encode(countryISO, regionCode));

        // Idempotent — skip if already registered and active
        if (_regions[regionId].id == bytes32(0)) {
            _regions[regionId] = DataTypes.Region({
                id: regionId,
                countryISO: countryISO,
                regionCode: regionCode,
                isActive: true,
                registeredVoterCount: 0,
                activeElectionCount: 0
            });
            _regionList.push(regionId);
            _totalRegions++;
            emit Events__RegionRegistered(regionId, countryISO, regionCode);
        }
    }

    /// @notice Batch-register multiple regions at once
    function batchRegisterRegions(
        string[] calldata countryISOs,
        string[] calldata regionCodes
    )
        external
        onlyRole(Constants.ADMIN_ROLE)
    {
        if (countryISOs.length != regionCodes.length) {
            revert Errors__OutOfBounds(countryISOs.length, 0, type(uint256).max);
        }
        for (uint256 i = 0; i < countryISOs.length; i++) {
            this.registerRegion(countryISOs[i], regionCodes[i]);
        }
    }

    function deactivateRegion(bytes32 regionId) external onlyRole(Constants.ADMIN_ROLE) {
        _requireActiveRegion(regionId);
        _regions[regionId].isActive = false;
        emit Events__RegionDeactivated(regionId);
    }

    function activateRegion(bytes32 regionId) external onlyRole(Constants.ADMIN_ROLE) {
        require(_regions[regionId].id != bytes32(0), "Region not registered");
        _regions[regionId].isActive = true;
        emit Events__RegionRegistered(regionId, _regions[regionId].countryISO, _regions[regionId].regionCode);
    }

    /// @notice Increment registered voter count — called by IdentityRegistry
    function incrementVoterCount(bytes32 regionId) external onlyRole(Constants.OPERATOR_ROLE) {
        _requireActiveRegion(regionId);
        _regions[regionId].registeredVoterCount++;
    }

    /// @notice Track active election count per region — called by ElectionFactory
    function incrementElectionCount(bytes32 regionId) external onlyRole(Constants.OPERATOR_ROLE) {
        _requireActiveRegion(regionId);
        _regions[regionId].activeElectionCount++;
    }

    function decrementElectionCount(bytes32 regionId) external onlyRole(Constants.OPERATOR_ROLE) {
        if (_regions[regionId].activeElectionCount > 0) {
            _regions[regionId].activeElectionCount--;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getRegion(bytes32 regionId) external view returns (DataTypes.Region memory) {
        return _regions[regionId];
    }

    function isRegionActive(bytes32 regionId) external view returns (bool) {
        return _regions[regionId].isActive;
    }

    function regionExists(bytes32 regionId) external view returns (bool) {
        return _regions[regionId].id != bytes32(0);
    }

    function computeRegionId(string calldata countryISO, string calldata regionCode)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(countryISO, regionCode));
    }

    function getAllRegions() external view returns (bytes32[] memory) {
        return _regionList;
    }

    function totalRegions() external view returns (uint256) {
        return _totalRegions;
    }

    function getRegionsPaginated(uint256 offset, uint256 limit)
        external
        view
        returns (DataTypes.Region[] memory regions, uint256 total)
    {
        total = _regionList.length;
        if (offset >= total) return (new DataTypes.Region[](0), total);
        uint256 end = offset + limit > total ? total : offset + limit;
        uint256 count = end - offset;
        regions = new DataTypes.Region[](count);
        for (uint256 i = 0; i < count; i++) {
            regions[i] = _regions[_regionList[offset + i]];
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _requireActiveRegion(bytes32 regionId) internal view {
        if (!_regions[regionId].isActive) revert Errors__RegionNotActive(regionId);
    }

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
