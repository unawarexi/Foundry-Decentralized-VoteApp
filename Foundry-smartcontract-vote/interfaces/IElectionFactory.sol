// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IElectionFactory {
    function createElection(
        bytes32 regionHash,
        DataTypes.ElectionType electionType,
        uint64 startTime,
        uint64 endTime,
        uint256 voteFeeUSD,
        DataTypes.PaymentToken acceptedToken,
        bool requireBiometric,
        bool allowRevote,
        uint8 minVerificationLevel
    ) external returns (uint256 electionId);

    function activateElection(uint256 electionId) external;
    function pauseElection(uint256 electionId, string calldata reason) external;
    function resumeElection(uint256 electionId) external;
    function cancelElection(uint256 electionId, string calldata reason) external;
    function startTallying(uint256 electionId) external;
    function finalizeElection(uint256 electionId) external;

    function getElection(uint256 electionId) external view returns (DataTypes.Election memory);
    function getElectionStatus(uint256 electionId) external view returns (DataTypes.ElectionStatus);
    function isElectionActive(uint256 electionId) external view returns (bool);
    function totalElections() external view returns (uint256);
    function getElectionsByRegion(bytes32 regionHash) external view returns (uint256[] memory);
    function incrementVoteCount(uint256 electionId) external;
}
