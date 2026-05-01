// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DataTypes} from "../src/types/DataTypes.sol";

interface IVoteProtocol {
    struct CastVoteParams {
        uint256 electionId;
        uint256 candidateId;
        bytes32 identityHash;
        bytes32 voteNonce;        // unique nonce for this vote (prevents replay)
        uint64 deadline;
        bytes backendSig;         // FastAPI signature authorising this vote
    }

    function castVote(CastVoteParams calldata params) external;

    function getVoteRecord(address voter, uint256 electionId) external view returns (DataTypes.VoteRecord memory);
    function hasVoted(address voter, uint256 electionId) external view returns (bool);
    function getElectionResults(uint256 electionId) external view returns (uint256[] memory candidateIds, uint256[] memory voteCounts);
    function getWinner(uint256 electionId) external view returns (uint256 candidateId, uint256 voteCount);
}
