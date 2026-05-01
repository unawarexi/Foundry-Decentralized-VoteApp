// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface ICandidateRegistry {
    function registerCandidate(
        uint256 electionId,
        address wallet,
        bytes32 profileIpfsHash,
        bytes32 manifestoIpfsHash,
        bytes32 partyId
    ) external returns (uint256 candidateId);

    function verifyCandidate(uint256 candidateId) external;
    function disqualifyCandidate(uint256 candidateId, bytes32 reason) external;
    function withdrawCandidate(uint256 candidateId) external;
    function updateManifesto(uint256 candidateId, bytes32 newIpfsHash) external;
    function updatePopularityScore(uint256 candidateId, uint256 newScore) external;
    function applyPopularityDelta(uint256 candidateId, int256 delta) external;
    function incrementVoteCount(uint256 candidateId) external;

    function getCandidate(uint256 candidateId) external view returns (DataTypes.Candidate memory);
    function getCandidatesForElection(uint256 electionId) external view returns (uint256[] memory);
    function isCandidateActive(uint256 candidateId) external view returns (bool);
    function totalCandidates() external view returns (uint256);
}
