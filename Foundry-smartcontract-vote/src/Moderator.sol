// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Legacy alias — FraudDetection is the production moderation contract
import {FraudDetection} from "./FraudDetection.sol";

/// @dev Use FraudDetection directly in all new code.
contract Moderator is FraudDetection {}