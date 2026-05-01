// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {IdentityRegistry} from "../src/identity/IdentityRegistry.sol";
import {RegionRegistry} from "../src/identity/RegionRegistry.sol";
import {ZKVerifier} from "../src/identity/ZKVerifier.sol";
import {CandidateRegistry} from "../src/CandidateRegistry.sol";
import {PoliticalPartyRegistry} from "../src/PoliticalPartyRegistry.sol";
import {ElectionFactory} from "../src/core/ElectionFactory.sol";
import {VoteProtocol} from "../src/core/VoteProtocol.sol";
import {VoteFeeEscrow} from "../src/payments/VoteFeeEscrow.sol";
import {FraudDetection} from "../src/FraudDetection.sol";
import {ForumGovernance} from "../src/ForumGovernance.sol";
import {Constants} from "../src/types/Constants.sol";

/// @title DeploySystem
/// @notice Deploys the full VoteSecure protocol behind UUPS proxies.
///         Run with:
///           forge script script/DeploySystem.s.sol --rpc-url $RPC_URL --broadcast --verify
///
/// @dev Each contract is deployed as: impl → proxy(impl, initData)
///      All proxy addresses are logged to console for .env population.
contract DeploySystem is Script {
    // ── Deployed addresses ──
    address public identityRegistryProxy;
    address public regionRegistryProxy;
    address public zkVerifierProxy;
    address public candidateRegistryProxy;
    address public partyRegistryProxy;
    address public electionFactoryProxy;
    address public voteProtocolProxy;
    address public voteFeeEscrowProxy;
    address public fraudDetectionProxy;
    address public forumGovernanceProxy;

    function run() external {
        // Load deployment config from env
        uint256 deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer    = vm.addr(deployerKey);
        address admin       = vm.envOr("ADMIN_ADDRESS", deployer);
        address backendSigner = vm.envAddress("BACKEND_SIGNER_ADDRESS");
        address treasury    = vm.envOr("TREASURY_ADDRESS", deployer);
        address usdt        = vm.envOr("USDT_ADDRESS", address(0));
        address usdc        = vm.envOr("USDC_ADDRESS", address(0));

        console2.log("=== VoteSecure Protocol Deployment ===");
        console2.log("Deployer:       ", deployer);
        console2.log("Admin:          ", admin);
        console2.log("Backend signer: ", backendSigner);
        console2.log("Treasury:       ", treasury);
        console2.log("Chain ID:       ", block.chainid);

        vm.startBroadcast(deployerKey);

        // ── 1. RegionRegistry ──
        RegionRegistry regionImpl = new RegionRegistry();
        regionRegistryProxy = address(new ERC1967Proxy(
            address(regionImpl),
            abi.encodeCall(RegionRegistry.initialize, (admin))
        ));
        console2.log("RegionRegistry:       ", regionRegistryProxy);

        // ── 2. IdentityRegistry ──
        IdentityRegistry identityImpl = new IdentityRegistry();
        identityRegistryProxy = address(new ERC1967Proxy(
            address(identityImpl),
            abi.encodeCall(IdentityRegistry.initialize, (admin, backendSigner))
        ));
        console2.log("IdentityRegistry:     ", identityRegistryProxy);

        // ── 3. ZKVerifier ──
        ZKVerifier zkImpl = new ZKVerifier();
        zkVerifierProxy = address(new ERC1967Proxy(
            address(zkImpl),
            abi.encodeCall(ZKVerifier.initialize, (admin, bytes32(0)))
        ));
        console2.log("ZKVerifier:           ", zkVerifierProxy);

        // ── 4. PoliticalPartyRegistry ──
        PoliticalPartyRegistry partyImpl = new PoliticalPartyRegistry();
        partyRegistryProxy = address(new ERC1967Proxy(
            address(partyImpl),
            abi.encodeCall(PoliticalPartyRegistry.initialize, (admin))
        ));
        console2.log("PartyRegistry:        ", partyRegistryProxy);

        // ── 5. CandidateRegistry ──
        CandidateRegistry candidateImpl = new CandidateRegistry();
        candidateRegistryProxy = address(new ERC1967Proxy(
            address(candidateImpl),
            abi.encodeCall(CandidateRegistry.initialize, (admin))
        ));
        console2.log("CandidateRegistry:    ", candidateRegistryProxy);

        // ── 6. ElectionFactory ──
        ElectionFactory electionImpl = new ElectionFactory();
        electionFactoryProxy = address(new ERC1967Proxy(
            address(electionImpl),
            abi.encodeCall(
                ElectionFactory.initialize,
                (admin, regionRegistryProxy, candidateRegistryProxy)
            )
        ));
        console2.log("ElectionFactory:      ", electionFactoryProxy);

        // ── 7. VoteFeeEscrow ──
        address[] memory tokens = new address[](2);
        tokens[0] = usdt;
        tokens[1] = usdc;
        VoteFeeEscrow escrowImpl = new VoteFeeEscrow();
        voteFeeEscrowProxy = address(new ERC1967Proxy(
            address(escrowImpl),
            abi.encodeCall(VoteFeeEscrow.initialize, (admin, treasury, tokens))
        ));
        console2.log("VoteFeeEscrow:        ", voteFeeEscrowProxy);

        // ── 8. VoteProtocol ──
        VoteProtocol voteImpl = new VoteProtocol();
        voteProtocolProxy = address(new ERC1967Proxy(
            address(voteImpl),
            abi.encodeCall(
                VoteProtocol.initialize,
                (
                    admin,
                    identityRegistryProxy,
                    electionFactoryProxy,
                    candidateRegistryProxy,
                    voteFeeEscrowProxy
                )
            )
        ));
        console2.log("VoteProtocol:         ", voteProtocolProxy);

        // ── 9. FraudDetection ──
        FraudDetection fraudImpl = new FraudDetection();
        fraudDetectionProxy = address(new ERC1967Proxy(
            address(fraudImpl),
            abi.encodeCall(FraudDetection.initialize, (admin, identityRegistryProxy))
        ));
        console2.log("FraudDetection:       ", fraudDetectionProxy);

        // ── 10. ForumGovernance ──
        ForumGovernance forumImpl = new ForumGovernance();
        forumGovernanceProxy = address(new ERC1967Proxy(
            address(forumImpl),
            abi.encodeCall(
                ForumGovernance.initialize,
                (admin, candidateRegistryProxy, identityRegistryProxy)
            )
        ));
        console2.log("ForumGovernance:      ", forumGovernanceProxy);

        // ── Post-deploy role wiring ──
        _wireRoles(admin, backendSigner);

        vm.stopBroadcast();

        console2.log("\n=== Deployment Complete ===");
        _printEnvBlock();
    }

    function _wireRoles(address admin, address backendSigner) internal {
        // Grant VoteProtocol the OPERATOR_ROLE on IdentityRegistry, CandidateRegistry, ElectionFactory
        IdentityRegistry(identityRegistryProxy).grantRole(Constants.OPERATOR_ROLE, voteProtocolProxy);
        CandidateRegistry(candidateRegistryProxy).grantRole(Constants.OPERATOR_ROLE, voteProtocolProxy);
        ElectionFactory(electionFactoryProxy).grantRole(Constants.OPERATOR_ROLE, voteProtocolProxy);
        ElectionFactory(electionFactoryProxy).grantRole(Constants.TALLY_ROLE, voteProtocolProxy);

        // Grant FraudDetection the FRAUD_ORACLE_ROLE on IdentityRegistry
        IdentityRegistry(identityRegistryProxy).grantRole(Constants.FRAUD_ORACLE_ROLE, fraudDetectionProxy);

        // Grant ForumGovernance OPERATOR_ROLE on CandidateRegistry
        CandidateRegistry(candidateRegistryProxy).grantRole(Constants.OPERATOR_ROLE, forumGovernanceProxy);

        // Grant ElectionFactory ELECTION_CREATOR_ROLE on CandidateRegistry
        CandidateRegistry(candidateRegistryProxy).grantRole(
            Constants.ELECTION_CREATOR_ROLE,
            electionFactoryProxy
        );

        // Grant VoteFeeEscrow OPERATOR_ROLE to VoteProtocol
        VoteFeeEscrow(payable(voteFeeEscrowProxy)).grantRole(Constants.OPERATOR_ROLE, voteProtocolProxy);

        // Grant RegionRegistry OPERATOR_ROLE to ElectionFactory
        RegionRegistry(regionRegistryProxy).grantRole(Constants.OPERATOR_ROLE, electionFactoryProxy);

        // Update backend signer on VoteProtocol
        VoteProtocol(voteProtocolProxy).updateBackendSigner(admin, backendSigner);

        console2.log("Role wiring:          DONE");
    }

    function _printEnvBlock() internal view {
        console2.log("\n# Paste into .env:");
        console2.log("IDENTITY_REGISTRY_ADDRESS=", identityRegistryProxy);
        console2.log("REGION_REGISTRY_ADDRESS=", regionRegistryProxy);
        console2.log("ZK_VERIFIER_ADDRESS=", zkVerifierProxy);
        console2.log("CANDIDATE_REGISTRY_ADDRESS=", candidateRegistryProxy);
        console2.log("PARTY_REGISTRY_ADDRESS=", partyRegistryProxy);
        console2.log("ELECTION_FACTORY_ADDRESS=", electionFactoryProxy);
        console2.log("VOTE_PROTOCOL_ADDRESS=", voteProtocolProxy);
        console2.log("VOTE_FEE_ESCROW_ADDRESS=", voteFeeEscrowProxy);
        console2.log("FRAUD_DETECTION_ADDRESS=", fraudDetectionProxy);
        console2.log("FORUM_GOVERNANCE_ADDRESS=", forumGovernanceProxy);
    }
}
