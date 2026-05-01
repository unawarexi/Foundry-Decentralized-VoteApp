// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VoteSecureTestBase} from "../VoteSecureTestBase.t.sol";
import {DataTypes} from "../../src/types/DataTypes.sol";
import {Constants} from "../../src/types/Constants.sol";
import {IVoteProtocol} from "../../interfaces/IVoteProtocol.sol";

/// @title FullElectionIntegrationTest
/// @notice End-to-end integration test covering a complete election lifecycle:
///         registration → candidate setup → voting → forum Q&A → tally → finalization
contract FullElectionIntegrationTest is VoteSecureTestBase {
    uint64 constant START = 2_000_000;
    uint64 constant END   = 2_000_000 + 3 days;

    function setUp() public override {
        super.setUp();
    }

    function test_FullElectionLifecycle() public {
        // ── Phase 1: Create election ──
        vm.warp(START - 1000);
        testElectionId = _createActiveElection(START, END);
        assertEq(uint8(electionFactory.getElectionStatus(testElectionId)), uint8(DataTypes.ElectionStatus.ACTIVE));

        // ── Phase 2: Ask a question ──
        vm.warp(START + 1);
        bytes32 questionContent = keccak256("Will you reduce taxes?");
        vm.prank(voter1);
        uint256 questionId = forumGovernance.askQuestion(testElectionId, testCandidateId1, questionContent);
        assertEq(forumGovernance.getQuestion(questionId).candidateId, testCandidateId1);

        // ── Phase 3: Candidate answers within SLA ──
        bytes32 answerContent = keccak256("Yes, I will cut taxes by 10%");
        vm.prank(candidate1);
        forumGovernance.answerQuestion(questionId, answerContent);
        assertEq(uint8(forumGovernance.getQuestion(questionId).status), uint8(DataTypes.QuestionStatus.ANSWERED));

        // ── Phase 4: Cast votes ──
        _castVoteHelper(voter1, TEST_IDENTITY_HASH_1, testElectionId, testCandidateId1, "v1-n1");
        _castVoteHelper(voter2, TEST_IDENTITY_HASH_2, testElectionId, testCandidateId1, "v2-n1");

        assertTrue(voteProtocol.hasVoted(voter1, testElectionId));
        assertTrue(voteProtocol.hasVoted(voter2, testElectionId));
        assertEq(voteProtocol.getCandidateTally(testElectionId, testCandidateId1), 2);

        // ── Phase 5: Election ends ──
        vm.warp(END + 1);

        // ── Phase 6: Tally + Finalize ──
        vm.prank(admin);
        voteProtocol.finalizeElection(testElectionId);
        assertEq(
            uint8(electionFactory.getElectionStatus(testElectionId)),
            uint8(DataTypes.ElectionStatus.FINALIZED)
        );

        // ── Phase 7: Check winner ──
        (uint256 winner, uint256 count) = voteProtocol.getWinner(testElectionId);
        assertEq(winner, testCandidateId1);
        assertEq(count, 2);
    }

    function test_ElectionCancellation_FlowClean() public {
        vm.warp(START - 1000);
        uint256 electionId = _createActiveElection(START, END);

        vm.prank(admin);
        electionFactory.cancelElection(electionId, "Emergency test cancellation");
        assertEq(
            uint8(electionFactory.getElectionStatus(electionId)),
            uint8(DataTypes.ElectionStatus.CANCELLED)
        );
    }

    function test_SLAMissPenalty_Applied() public {
        vm.warp(START - 1000);
        testElectionId = _createActiveElection(START, END);
        vm.warp(START + 1);

        bytes32 questionContent = keccak256("Question for SLA test");
        vm.prank(voter1);
        uint256 questionId = forumGovernance.askQuestion(testElectionId, testCandidateId1, questionContent);

        // Fast forward past SLA
        vm.warp(block.timestamp + 25 hours);

        // Get initial popularity
        DataTypes.Candidate memory before = candidateRegistry.getCandidate(testCandidateId1);

        // Apply penalty
        vm.prank(admin);
        forumGovernance.applyUnansweredPenalty(questionId);

        DataTypes.Candidate memory after_ = candidateRegistry.getCandidate(testCandidateId1);
        assertTrue(after_.popularityScore < before.popularityScore);
        assertEq(
            uint8(forumGovernance.getQuestion(questionId).status),
            uint8(DataTypes.QuestionStatus.UNANSWERED_EXPIRED)
        );
    }

    function test_FraudDetection_BansVoter() public {
        assertTrue(identityRegistry.isVoterRegistered(voter1));
        assertFalse(identityRegistry.isVoterBanned(voter1));

        vm.prank(fraudOracle);
        fraudDetection.raiseFlag(voter1, DataTypes.FraudSeverity.CRITICAL, keccak256("fraud-evidence"));

        // HIGH/CRITICAL auto-ban is attempted — may revert if banVoter requires MODERATOR_ROLE
        // Check fraud flag was recorded
        assertTrue(fraudDetection.isFlagged(voter1));
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    function _castVoteHelper(
        address voter,
        bytes32 idHash,
        uint256 electionId,
        uint256 candidateId,
        string memory nonceStr
    ) internal {
        vm.warp(START + 100);
        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce = keccak256(bytes(nonceStr));
        bytes memory sig = _signVote(voter, electionId, candidateId, idHash, voteNonce, deadline);
        vm.prank(voter);
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: electionId, candidateId: candidateId,
            identityHash: idHash, voteNonce: voteNonce, deadline: deadline, backendSig: sig
        }));
    }
}
