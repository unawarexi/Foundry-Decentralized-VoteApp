// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IDonationDistributor {
    function deposit(bytes32 partyId, address token, uint256 amount) external;
    function withdraw(bytes32 partyId, address token, uint256 amount) external;
    function getBalance(bytes32 partyId, address token) external view returns (uint256);
    function distributeToCandidates(bytes32 partyId, uint256[] calldata candidateIds, uint256[] calldata amounts) external;
}