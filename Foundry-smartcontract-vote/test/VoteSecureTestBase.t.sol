// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {IdentityRegistry} from "../src/identity/IdentityRegistry.sol";
import {RegionRegistry} from "../src/identity/RegionRegistry.sol";
import {CandidateRegistry} from "../src/CandidateRegistry.sol";
import {PoliticalPartyRegistry} from "../src/PoliticalPartyRegistry.sol";
import {ElectionFactory} from "../src/core/ElectionFactory.sol";
import {VoteProtocol} from "../src/core/VoteProtocol.sol";
import {VoteFeeEscrow} from "../src/payments/VoteFeeEscrow.sol";
import {FraudDetection} from "../src/FraudDetection.sol";
import {ForumGovernance} from "../src/ForumGovernance.sol";
import {DataTypes} from "../src/types/DataTypes.sol";
import {Constants} from "../src/types/Constants.sol";

/// @title VoteSecureTestBase
/// @notice Base test contract with full protocol deployment and common helpers.
///         All unit and integration tests inherit from this.
abstract contract VoteSecureTestBase is Test {
    // ── Actor addresses ──
    address internal admin;
    address internal backendSigner;
    address internal fraudOracle;
    address internal treasury;
    address internal voter1;
    address internal voter2;
    address internal candidate1;
    address internal candidate2;

    uint256 internal adminKey;
    uint256 internal backendSignerKey;
    uint256 internal voter1Key;
    uint256 internal voter2Key;

    // ── Deployed contracts ──
    IdentityRegistry    internal identityRegistry;
    RegionRegistry      internal regionRegistry;
    CandidateRegistry   internal candidateRegistry;
    PoliticalPartyRegistry internal partyRegistry;
    ElectionFactory     internal electionFactory;
    VoteProtocol        internal voteProtocol;
    VoteFeeEscrow       internal voteFeeEscrow;
    FraudDetection      internal fraudDetection;
    ForumGovernance     internal forumGovernance;

    // ── Test fixtures ──
    bytes32 internal constant TEST_REGION_HASH = keccak256(abi.encode("NG", "LAGOS"));
    bytes32 internal constant TEST_IDENTITY_HASH_1 = keccak256("voter1-identity");
    bytes32 internal constant TEST_IDENTITY_HASH_2 = keccak256("voter2-identity");
    bytes32 internal constant TEST_PROFILE_IPFS = keccak256("candidate-profile");
    bytes32 internal constant TEST_MANIFESTO_IPFS = keccak256("candidate-manifesto");

    uint256 internal testElectionId;
    uint256 internal testCandidateId1;
    uint256 internal testCandidateId2;

    function setUp() public virtual {
        // Generate deterministic keys
        adminKey        = 0xA11CE;
        backendSignerKey = 0xBAC1;
        voter1Key       = 0xB01CE1;
        voter2Key       = 0xB01CE2;

        admin         = vm.addr(adminKey);
        backendSigner = vm.addr(backendSignerKey);
        fraudOracle   = makeAddr("fraudOracle");
        treasury      = makeAddr("treasury");
        voter1        = vm.addr(voter1Key);
        voter2        = vm.addr(voter2Key);
        candidate1    = makeAddr("candidate1");
        candidate2    = makeAddr("candidate2");

        _deploySystem();
        _wireRoles();
        _setupRegion();
        _registerVoters();
    }

    // ──────────────────────────────────────────────────────────────────────────
    //  DEPLOYMENT
    // ──────────────────────────────────────────────────────────────────────────

    function _deploySystem() internal {
        vm.startPrank(admin);

        // RegionRegistry
        RegionRegistry regionImpl = new RegionRegistry();
        regionRegistry = RegionRegistry(address(
            new ERC1967Proxy(address(regionImpl), abi.encodeCall(RegionRegistry.initialize, (admin)))
        ));

        // IdentityRegistry
        IdentityRegistry identityImpl = new IdentityRegistry();
        identityRegistry = IdentityRegistry(address(
            new ERC1967Proxy(
                address(identityImpl),
                abi.encodeCall(IdentityRegistry.initialize, (admin, backendSigner))
            )
        ));

        // CandidateRegistry
        CandidateRegistry candidateImpl = new CandidateRegistry();
        candidateRegistry = CandidateRegistry(address(
            new ERC1967Proxy(address(candidateImpl), abi.encodeCall(CandidateRegistry.initialize, (admin)))
        ));

        // PoliticalPartyRegistry
        PoliticalPartyRegistry partyImpl = new PoliticalPartyRegistry();
        partyRegistry = PoliticalPartyRegistry(address(
            new ERC1967Proxy(address(partyImpl), abi.encodeCall(PoliticalPartyRegistry.initialize, (admin)))
        ));

        // ElectionFactory
        ElectionFactory electionImpl = new ElectionFactory();
        electionFactory = ElectionFactory(address(
            new ERC1967Proxy(
                address(electionImpl),
                abi.encodeCall(
                    ElectionFactory.initialize,
                    (admin, address(regionRegistry), address(candidateRegistry))
                )
            )
        ));

        // VoteFeeEscrow
        address[] memory tokens = new address[](0);
        VoteFeeEscrow escrowImpl = new VoteFeeEscrow();
        voteFeeEscrow = VoteFeeEscrow(payable(address(
            new ERC1967Proxy(
                address(escrowImpl),
                abi.encodeCall(VoteFeeEscrow.initialize, (admin, treasury, tokens))
            )
        )));

        // VoteProtocol
        VoteProtocol voteImpl = new VoteProtocol();
        voteProtocol = VoteProtocol(address(
            new ERC1967Proxy(
                address(voteImpl),
                abi.encodeCall(
                    VoteProtocol.initialize,
                    (
                        admin,
                        address(identityRegistry),
                        address(electionFactory),
                        address(candidateRegistry),
                        address(voteFeeEscrow)
                    )
                )
            )
        ));

        // FraudDetection
        FraudDetection fraudImpl = new FraudDetection();
        fraudDetection = FraudDetection(address(
            new ERC1967Proxy(
                address(fraudImpl),
                abi.encodeCall(FraudDetection.initialize, (admin, address(identityRegistry)))
            )
        ));

        // ForumGovernance
        ForumGovernance forumImpl = new ForumGovernance();
        forumGovernance = ForumGovernance(address(
            new ERC1967Proxy(
                address(forumImpl),
                abi.encodeCall(
                    ForumGovernance.initialize,
                    (admin, address(candidateRegistry), address(identityRegistry))
                )
            )
        ));

        vm.stopPrank();
    }

    function _wireRoles() internal {
        vm.startPrank(admin);

        // VoteProtocol needs OPERATOR_ROLE on Identity/Candidate/Election + TALLY_ROLE
        identityRegistry.grantRole(Constants.OPERATOR_ROLE, address(voteProtocol));
        candidateRegistry.grantRole(Constants.OPERATOR_ROLE, address(voteProtocol));
        electionFactory.grantRole(Constants.OPERATOR_ROLE, address(voteProtocol));
        electionFactory.grantRole(Constants.TALLY_ROLE, address(voteProtocol));

        // ElectionFactory needs ELECTION_CREATOR_ROLE on CandidateRegistry
        candidateRegistry.grantRole(Constants.ELECTION_CREATOR_ROLE, address(electionFactory));

        // ForumGovernance needs OPERATOR_ROLE on CandidateRegistry
        candidateRegistry.grantRole(Constants.OPERATOR_ROLE, address(forumGovernance));

        // FraudDetection needs FRAUD_ORACLE_ROLE (already set in init)
        // Grant fraudOracle address FRAUD_ORACLE_ROLE
        fraudDetection.grantRole(Constants.FRAUD_ORACLE_ROLE, fraudOracle);

        // RegionRegistry needs OPERATOR_ROLE for ElectionFactory
        regionRegistry.grantRole(Constants.OPERATOR_ROLE, address(electionFactory));

        // Update backend signer on VoteProtocol
        voteProtocol.updateBackendSigner(admin, backendSigner);

        vm.stopPrank();
    }

    function _setupRegion() internal {
        vm.prank(admin);
        regionRegistry.registerRegion("NG", "LAGOS");
    }

    function _registerVoters() internal {
        _registerVoter(voter1, TEST_IDENTITY_HASH_1, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC);
        _registerVoter(voter2, TEST_IDENTITY_HASH_2, TEST_REGION_HASH, DataTypes.VerificationLevel.BIOMETRIC);
    }

    // ──────────────────────────────────────────────────────────────────────────
    //  SIGNATURE HELPERS
    // ──────────────────────────────────────────────────────────────────────────

    function _buildRegistrationTypehash() internal pure returns (bytes32) {
        return keccak256(
            "Registration(address wallet,bytes32 identityHash,bytes32 regionHash,uint8 level,uint64 deadline,bytes32 nonce)"
        );
    }

    function _buildVoteTypehash() internal pure returns (bytes32) {
        return keccak256(
            "Vote(address voter,uint256 electionId,uint256 candidateId,bytes32 identityHash,bytes32 voteNonce,uint64 deadline)"
        );
    }

    function _signRegistration(
        address wallet,
        bytes32 identityHash,
        bytes32 regionHash,
        DataTypes.VerificationLevel level,
        uint64 deadline,
        bytes32 nonce
    ) internal view returns (bytes memory sig) {
        bytes32 domainSep = identityRegistry.domainSeparator();
        bytes32 structHash = keccak256(abi.encode(
            _buildRegistrationTypehash(),
            wallet, identityHash, regionHash, uint8(level), deadline, nonce
        ));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSep, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(backendSignerKey, digest);
        sig = abi.encodePacked(r, s, v);
    }

    function _signVote(
        address voter,
        uint256 electionId,
        uint256 candidateId,
        bytes32 identityHash,
        bytes32 voteNonce,
        uint64 deadline
    ) internal view returns (bytes memory sig) {
        bytes32 domainSep = voteProtocol.domainSeparator();
        bytes32 structHash = keccak256(abi.encode(
            _buildVoteTypehash(),
            voter, electionId, candidateId, identityHash, voteNonce, deadline
        ));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSep, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(backendSignerKey, digest);
        sig = abi.encodePacked(r, s, v);
    }

    // ──────────────────────────────────────────────────────────────────────────
    //  COMMON ACTIONS
    // ──────────────────────────────────────────────────────────────────────────

    function _registerVoter(
        address wallet,
        bytes32 identityHash,
        bytes32 regionHash,
        DataTypes.VerificationLevel level
    ) internal {
        uint64 deadline = uint64(block.timestamp + 15 minutes);
        bytes32 nonce = keccak256(abi.encodePacked(wallet, block.timestamp));
        bytes memory sig = _signRegistration(wallet, identityHash, regionHash, level, deadline, nonce);
        vm.prank(wallet);
        identityRegistry.registerVoter(identityHash, regionHash, level, deadline, nonce, sig);
    }

    function _createActiveElection(uint64 start, uint64 end)
        internal
        returns (uint256 electionId)
    {
        vm.prank(admin);
        electionId = electionFactory.createElection(
            TEST_REGION_HASH,
            DataTypes.ElectionType.LOCAL_GOVERNMENT,
            start,
            end,
            100,
            DataTypes.PaymentToken.USDT,
            false,
            false,
            uint8(DataTypes.VerificationLevel.BIOMETRIC)
        );

        // Register candidates
        vm.startPrank(admin);
        uint256 c1 = candidateRegistry.registerCandidate(
            electionId, candidate1, TEST_PROFILE_IPFS, TEST_MANIFESTO_IPFS, bytes32(0)
        );
        uint256 c2 = candidateRegistry.registerCandidate(
            electionId, candidate2, TEST_PROFILE_IPFS, TEST_MANIFESTO_IPFS, bytes32(0)
        );
        // Verify them
        candidateRegistry.grantRole(Constants.OPERATOR_ROLE, admin);
        candidateRegistry.verifyCandidate(c1);
        candidateRegistry.verifyCandidate(c2);

        electionFactory.activateElection(electionId);
        vm.stopPrank();

        testCandidateId1 = c1;
        testCandidateId2 = c2;
    }
}
