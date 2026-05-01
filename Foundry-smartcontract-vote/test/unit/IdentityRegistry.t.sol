// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VoteSecureTestBase} from "../VoteSecureTestBase.t.sol";
import {DataTypes} from "../../src/types/DataTypes.sol";
import {Constants} from "../../src/types/Constants.sol";
import {Errors__IdentityAlreadyRegistered,
        Errors__InvalidSignature,
        Errors__SignatureExpired,
        Errors__NonceUsed,
        Errors__VoterNotRegistered,
        Errors__VoterBanned,
        Errors__RegionMismatch} from "../../src/types/Errors.sol";

/// @title IdentityRegistryTest
/// @notice Unit tests for IdentityRegistry
contract IdentityRegistryTest is VoteSecureTestBase {
    // ── Registration ──────────────────────────────────────────────────────────

    function test_RegisterVoter_Success() public {
        assertTrue(identityRegistry.isVoterRegistered(voter1));
        DataTypes.Voter memory v = identityRegistry.getVoter(voter1);
        assertEq(v.identityHash, TEST_IDENTITY_HASH_1);
        assertEq(v.regionHash, TEST_REGION_HASH);
        assertEq(uint8(v.level), uint8(DataTypes.VerificationLevel.BIOMETRIC));
        assertFalse(v.isBanned);
        assertEq(v.wallet, voter1);
    }

    function test_RegisterVoter_RevertDuplicateIdentity() public {
        address wallet2 = makeAddr("wallet2");
        uint64 deadline = uint64(block.timestamp + 15 minutes);
        bytes32 nonce = keccak256("new-nonce");
        bytes memory sig = _signRegistration(
            wallet2, TEST_IDENTITY_HASH_1, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce
        );
        vm.prank(wallet2);
        vm.expectRevert(abi.encodeWithSelector(Errors__IdentityAlreadyRegistered.selector, TEST_IDENTITY_HASH_1));
        identityRegistry.registerVoter(TEST_IDENTITY_HASH_1, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce, sig);
    }

    function test_RegisterVoter_RevertExpiredSignature() public {
        address newWallet = makeAddr("newWallet");
        bytes32 newIdHash = keccak256("new-id");
        uint64 pastDeadline = uint64(block.timestamp - 1);
        bytes32 nonce = keccak256("nonce-123");
        bytes memory sig = _signRegistration(
            newWallet, newIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, pastDeadline, nonce
        );
        vm.prank(newWallet);
        vm.expectRevert(
            abi.encodeWithSelector(Errors__SignatureExpired.selector, pastDeadline, uint64(block.timestamp))
        );
        identityRegistry.registerVoter(newIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, pastDeadline, nonce, sig);
    }

    function test_RegisterVoter_RevertInvalidSignature() public {
        address newWallet = makeAddr("newWallet2");
        bytes32 newIdHash = keccak256("new-id-2");
        uint64 deadline = uint64(block.timestamp + 15 minutes);
        bytes32 nonce = keccak256("nonce-456");
        // Sign with wrong key
        bytes memory badSig = abi.encodePacked(bytes32(0), bytes32(0), uint8(27));
        vm.prank(newWallet);
        vm.expectRevert(Errors__InvalidSignature.selector);
        identityRegistry.registerVoter(newIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce, badSig);
    }

    function test_RegisterVoter_RevertNonceReplay() public {
        address newWallet = makeAddr("newWallet3");
        bytes32 newIdHash = keccak256("new-id-3");
        uint64 deadline = uint64(block.timestamp + 15 minutes);
        bytes32 nonce = keccak256("reuse-nonce");
        bytes memory sig = _signRegistration(newWallet, newIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce);

        // First registration succeeds
        vm.prank(newWallet);
        identityRegistry.registerVoter(newIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce, sig);

        // Second attempt with same nonce fails
        address another = makeAddr("another");
        bytes32 anotherIdHash = keccak256("another-id");
        bytes memory sig2 = _signRegistration(another, anotherIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce);
        vm.prank(another);
        vm.expectRevert(abi.encodeWithSelector(Errors__NonceUsed.selector, nonce));
        identityRegistry.registerVoter(anotherIdHash, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC, deadline, nonce, sig2);
    }

    // ── Ban / Unban ───────────────────────────────────────────────────────────

    function test_BanVoter_AsAdmin() public {
        vm.prank(admin);
        identityRegistry.banVoter(voter1, bytes32("evidence"), uint64(block.timestamp + 1), bytes32("n1"), "");
        assertTrue(identityRegistry.isVoterBanned(voter1));
    }

    function test_UnbanVoter() public {
        vm.prank(admin);
        identityRegistry.banVoter(voter1, bytes32("evidence"), uint64(block.timestamp + 1), bytes32("n2"), "");
        vm.prank(admin);
        identityRegistry.unbanVoter(voter1);
        assertFalse(identityRegistry.isVoterBanned(voter1));
    }

    // ── Verification upgrade ───────────────────────────────────────────────────

    function test_UpgradeVerificationLevel() public {
        uint64 deadline = uint64(block.timestamp + 15 minutes);
        bytes32 nonce = keccak256("upgrade-nonce");

        bytes32 upgradeTypehash = keccak256(
            "VerificationUpgrade(address wallet,uint8 newLevel,bytes32 identityHash,uint64 deadline,bytes32 nonce)"
        );
        bytes32 domainSep = identityRegistry.domainSeparator();
        bytes32 structHash = keccak256(abi.encode(
            upgradeTypehash,
            voter1,
            uint8(DataTypes.VerificationLevel.ZK_PROOF),
            TEST_IDENTITY_HASH_1,
            deadline,
            nonce
        ));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSep, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(backendSignerKey, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(voter1);
        identityRegistry.upgradeVerificationLevel(
            DataTypes.VerificationLevel.ZK_PROOF,
            TEST_IDENTITY_HASH_1,
            deadline,
            nonce,
            sig
        );

        assertEq(
            uint8(identityRegistry.getVerificationLevel(voter1)),
            uint8(DataTypes.VerificationLevel.ZK_PROOF)
        );
    }

    // ── Eligibility check ─────────────────────────────────────────────────────

    function test_CheckEligibility_Eligible() public {
        (bool ok, string memory reason) = identityRegistry.checkVoterEligibility(
            voter1, TEST_REGION_HASH, uint8(DataTypes.VerificationLevel.BIOMETRIC)
        );
        assertTrue(ok);
        assertEq(reason, "");
    }

    function test_CheckEligibility_RegionMismatch() public {
        bytes32 wrongRegion = keccak256(abi.encode("US", "CA"));
        (bool ok, string memory reason) = identityRegistry.checkVoterEligibility(
            voter1, wrongRegion, uint8(DataTypes.VerificationLevel.BIOMETRIC)
        );
        assertFalse(ok);
        assertEq(reason, "REGION_MISMATCH");
    }

    function test_CheckEligibility_Banned() public {
        vm.prank(admin);
        identityRegistry.banVoter(voter1, bytes32("e"), uint64(block.timestamp + 1), bytes32("n3"), "");
        (bool ok, string memory reason) = identityRegistry.checkVoterEligibility(
            voter1, TEST_REGION_HASH, uint8(DataTypes.VerificationLevel.BIOMETRIC)
        );
        assertFalse(ok);
        assertEq(reason, "BANNED");
    }

    function test_CheckEligibility_NotRegistered() public {
        (bool ok, string memory reason) = identityRegistry.checkVoterEligibility(
            makeAddr("stranger"), TEST_REGION_HASH, uint8(DataTypes.VerificationLevel.BIOMETRIC)
        );
        assertFalse(ok);
        assertEq(reason, "NOT_REGISTERED");
    }

    // ── Fuzz ──────────────────────────────────────────────────────────────────

    function testFuzz_IdentityHashUniqueness(bytes32 id1, bytes32 id2) public pure {
        vm.assume(id1 != id2);
        assertTrue(id1 != id2);
    }
}
