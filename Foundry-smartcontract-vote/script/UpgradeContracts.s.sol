// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {IdentityRegistry} from "../src/identity/IdentityRegistry.sol";
import {RegionRegistry} from "../src/identity/RegionRegistry.sol";
import {CandidateRegistry} from "../src/CandidateRegistry.sol";
import {ElectionFactory} from "../src/core/ElectionFactory.sol";
import {VoteProtocol} from "../src/core/VoteProtocol.sol";
import {VoteFeeEscrow} from "../src/payments/VoteFeeEscrow.sol";
import {FraudDetection} from "../src/FraudDetection.sol";
import {ForumGovernance} from "../src/ForumGovernance.sol";
import {Constants} from "../src/types/Constants.sol";

/// @title UpgradeContracts
/// @notice Upgrades existing UUPS proxies to new implementations.
///         Set UPGRADE_TARGET to control which contracts get upgraded.
///
///   UPGRADE_ALL=true → upgrades all contracts
///   Or set individual: UPGRADE_IDENTITY=true, UPGRADE_ELECTION=true, etc.
///
/// Run: forge script script/UpgradeContracts.s.sol --rpc-url $RPC_URL --broadcast
contract UpgradeContracts is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        bool upgradeAll = vm.envOr("UPGRADE_ALL", false);

        vm.startBroadcast(deployerKey);

        if (upgradeAll || vm.envOr("UPGRADE_IDENTITY", false)) {
            _upgradeIdentityRegistry();
        }
        if (upgradeAll || vm.envOr("UPGRADE_ELECTION", false)) {
            _upgradeElectionFactory();
        }
        if (upgradeAll || vm.envOr("UPGRADE_VOTE", false)) {
            _upgradeVoteProtocol();
        }
        if (upgradeAll || vm.envOr("UPGRADE_ESCROW", false)) {
            _upgradeVoteFeeEscrow();
        }
        if (upgradeAll || vm.envOr("UPGRADE_FRAUD", false)) {
            _upgradeFraudDetection();
        }
        if (upgradeAll || vm.envOr("UPGRADE_FORUM", false)) {
            _upgradeForumGovernance();
        }

        vm.stopBroadcast();
    }

    function _upgradeIdentityRegistry() internal {
        address proxy = vm.envAddress("IDENTITY_REGISTRY_ADDRESS");
        IdentityRegistry newImpl = new IdentityRegistry();
        IdentityRegistry(proxy).upgradeToAndCall(address(newImpl), "");
        console2.log("IdentityRegistry upgraded to:", address(newImpl));
    }

    function _upgradeElectionFactory() internal {
        address proxy = vm.envAddress("ELECTION_FACTORY_ADDRESS");
        ElectionFactory newImpl = new ElectionFactory();
        ElectionFactory(proxy).upgradeToAndCall(address(newImpl), "");
        console2.log("ElectionFactory upgraded to:", address(newImpl));
    }

    function _upgradeVoteProtocol() internal {
        address proxy = vm.envAddress("VOTE_PROTOCOL_ADDRESS");
        VoteProtocol newImpl = new VoteProtocol();
        VoteProtocol(proxy).upgradeToAndCall(address(newImpl), "");
        console2.log("VoteProtocol upgraded to:", address(newImpl));
    }

    function _upgradeVoteFeeEscrow() internal {
        address proxy = vm.envAddress("VOTE_FEE_ESCROW_ADDRESS");
        VoteFeeEscrow newImpl = new VoteFeeEscrow();
        VoteFeeEscrow(payable(proxy)).upgradeToAndCall(address(newImpl), "");
        console2.log("VoteFeeEscrow upgraded to:", address(newImpl));
    }

    function _upgradeFraudDetection() internal {
        address proxy = vm.envAddress("FRAUD_DETECTION_ADDRESS");
        FraudDetection newImpl = new FraudDetection();
        FraudDetection(proxy).upgradeToAndCall(address(newImpl), "");
        console2.log("FraudDetection upgraded to:", address(newImpl));
    }

    function _upgradeForumGovernance() internal {
        address proxy = vm.envAddress("FORUM_GOVERNANCE_ADDRESS");
        ForumGovernance newImpl = new ForumGovernance();
        ForumGovernance(proxy).upgradeToAndCall(address(newImpl), "");
        console2.log("ForumGovernance upgraded to:", address(newImpl));
    }
}
