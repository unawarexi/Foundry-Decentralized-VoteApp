// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IModerator {
    function banAddress(address target, bytes32 evidenceHash) external;
    function unbanAddress(address target) external;
    function isBanned(address target) external view returns (bool);
    function pause() external;
    function unpause() external;
}