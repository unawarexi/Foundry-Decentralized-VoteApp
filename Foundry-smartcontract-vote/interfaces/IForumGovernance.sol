// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IForumGovernance {
    function askQuestion(
        uint256 electionId,
        uint256 candidateId,
        bytes32 contentIpfsHash
    ) external returns (uint256 questionId);

    function answerQuestion(uint256 questionId, bytes32 answerIpfsHash) external;
    function upvoteQuestion(uint256 questionId) external;
    function downvoteQuestion(uint256 questionId) external;
    function applyUnansweredPenalty(uint256 questionId) external;
    function closeQuestion(uint256 questionId) external;

    function getQuestion(uint256 questionId) external view returns (DataTypes.Question memory);
    function getQuestionsForCandidate(uint256 candidateId) external view returns (uint256[] memory);
    function getQuestionsForElection(uint256 electionId) external view returns (uint256[] memory);
    function isSLAExpired(uint256 questionId) external view returns (bool);
}
