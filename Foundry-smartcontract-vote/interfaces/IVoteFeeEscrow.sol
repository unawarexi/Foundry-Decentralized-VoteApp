// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IVoteFeeEscrow {
    function lockFee(
        address voter,
        uint256 electionId,
        address token,
        uint256 amount
    ) external payable;

    function releaseFee(address voter, uint256 electionId) external;
    function refundFee(address voter, uint256 electionId) external;

    function getEscrow(address voter, uint256 electionId) external view returns (DataTypes.FeeEscrow memory);
    function getRequiredFee(uint256 electionId, address token) external view returns (uint256);
    function isTokenAccepted(address token) external view returns (bool);
    function treasury() external view returns (address);
}
