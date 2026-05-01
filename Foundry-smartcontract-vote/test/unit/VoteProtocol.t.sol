// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VoteSecureTestBase} from "../VoteSecureTestBase.t.sol";
import {DataTypes} from "../../src/types/DataTypes.sol";
import {Constants} from "../../src/types/Constants.sol";
import {IVoteProtocol} from "../../interfaces/IVoteProtocol.sol";
import {Errors__ElectionNotActive,
        Errors__AlreadyVoted,
        Errors__RegionMismatch,
        Errors__VoterBanned,
        Errors__InvalidSignature,
        Errors__CandidateNotActive} from "../../src/types/Errors.sol";

/// @title VoteProtocolTest
/// @notice Unit tests for VoteProtocol
contract VoteProtocolTest is VoteSecureTestBase {
    uint64 constant ELECTION_START = 1_000_000;
    uint64 constant ELECTION_END   = 1_000_000 + 7 days;

    function setUp() public override {
        super.setUp();
        vm.warp(ELECTION_START - 100); // time before election
        testElectionId = _createActiveElection(ELECTION_START, ELECTION_END);
        vm.warp(ELECTION_START + 1); // time during election
    }

    // ── Cast Vote ─────────────────────────────────────────────────────────────

    function test_CastVote_Success() public {
        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce = keccak256("vote-nonce-1");
        bytes memory sig = _signVote(voter1, testElectionId, testCandidateId1, TEST_IDENTITY_HASH_1, voteNonce, deadline);

        vm.prank(voter1);
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: testElectionId,
            candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1,
            voteNonce: voteNonce,
            deadline: deadline,
            backendSig: sig
        }));

        assertTrue(voteProtocol.hasVoted(voter1, testElectionId));
        assertEq(voteProtocol.getCandidateTally(testElectionId, testCandidateId1), 1);
    }

    function test_CastVote_RevertDuplicate_WhenRevoteDisabled() public {
        // First vote
        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce1 = keccak256("nonce-1");
        bytes memory sig1 = _signVote(voter1, testElectionId, testCandidateId1, TEST_IDENTITY_HASH_1, voteNonce1, deadline);
        vm.prank(voter1);
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: testElectionId, candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1, voteNonce: voteNonce1, deadline: deadline, backendSig: sig1
        }));

        // Second vote attempt
        bytes32 voteNonce2 = keccak256("nonce-2");
        bytes memory sig2 = _signVote(voter1, testElectionId, testCandidateId1, TEST_IDENTITY_HASH_1, voteNonce2, deadline);
        vm.prank(voter1);
        vm.expectRevert(abi.encodeWithSelector(Errors__AlreadyVoted.selector, voter1, testElectionId));
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: testElectionId, candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1, voteNonce: voteNonce2, deadline: deadline, backendSig: sig2
        }));
    }

    function test_CastVote_RevertElectionNotStarted() public {
        vm.warp(ELECTION_START - 200); // before start
        uint256 futureElectionId = _createActiveElection(ELECTION_START + 1 hours, ELECTION_END + 1 days);

        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce = keccak256("nonce-early");
        bytes memory sig = _signVote(voter1, futureElectionId, testCandidateId1, TEST_IDENTITY_HASH_1, voteNonce, deadline);

        vm.prank(voter1);
        vm.expectRevert(); // ElectionNotStarted
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: futureElectionId, candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1, voteNonce: voteNonce, deadline: deadline, backendSig: sig
        }));
    }

    function test_CastVote_RevertBannedVoter() public {
        vm.prank(admin);
        identityRegistry.banVoter(voter1, bytes32("e"), uint64(block.timestamp + 1), bytes32("ban-nonce"), "");

        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce = keccak256("nonce-banned");
        bytes memory sig = _signVote(voter1, testElectionId, testCandidateId1, TEST_IDENTITY_HASH_1, voteNonce, deadline);

        vm.prank(voter1);
        vm.expectRevert(abi.encodeWithSelector(Errors__VoterBanned.selector, voter1));
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: testElectionId, candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1, voteNonce: voteNonce, deadline: deadline, backendSig: sig
        }));
    }

    function test_CastVote_RevertInvalidSignature() public {
        uint64 deadline = uint64(block.timestamp + 10 minutes);
        bytes32 voteNonce = keccak256("nonce-badsig");

        vm.prank(voter1);
        vm.expectRevert(Errors__InvalidSignature.selector);
        voteProtocol.castVote(IVoteProtocol.CastVoteParams({
            electionId: testElectionId, candidateId: testCandidateId1,
            identityHash: TEST_IDENTITY_HASH_1, voteNonce: voteNonce, deadline: deadline,
            backendSig: abi.encodePacked(bytes32(0), bytes32(0), uint8(27))
        }));
    }

    // ── Tally ─────────────────────────────────────────────────────────────────

    function test_GetElectionResults() public {
        // voter1 → candidate1, voter2 → candidate1
        _castVote(voter1, TEST_IDENTITY_HASH_1, testElectionId, testCandidateId1, "n-v1");
        _castVote(voter2, TEST_IDENTITY_HASH_2, testElectionId, testCandidateId1, "n-v2");

        (uint256[] memory ids, uint256[] memory counts) = voteProtocol.getElectionResults(testElectionId);
        assertEq(ids.length, 2);

        // Find candidate1 in results
        for (uint i = 0; i < ids.length; i++) {
            if (ids[i] == testCandidateId1) {
                assertEq(counts[i], 2);
            } else {
                assertEq(counts[i], 0);
            }
        }
    }

    function test_GetWinner() public {
        _castVote(voter1, TEST_IDENTITY_HASH_1, testElectionId, testCandidateId2, "n-w1");
        _castVote(voter2, TEST_IDENTITY_HASH_2, testElectionId, testCandidateId2, "n-w2");

        (uint256 winner, uint256 count) = voteProtocol.getWinner(testElectionId);
        assertEq(winner, testCandidateId2);
        assertEq(count, 2);
    }

    // ── Fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_VoteHashUniqueness(bytes32 idHash, bytes32 nonce, uint256 candidateId) public view {
        bytes32 h1 = keccak256(abi.encodePacked(idHash, uint256(1), candidateId, nonce, block.chainid));
        bytes32 h2 = keccak256(abi.encodePacked(idHash, uint256(1), candidateId, keccak256(abi.encode(nonce)), block.chainid));
        assertTrue(h1 != h2);
    }

    // ── Internal helpers ──────────────────────────────────────────────────────

    function _castVote(
        address voter,
        bytes32 idHash,
        uint256 electionId,
        uint256 candidateId,
        string memory nonceStr
    ) internal {
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
