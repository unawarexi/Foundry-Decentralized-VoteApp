// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Legacy alias — VoteProtocol is the production contract
import {VoteProtocol} from "./core/VoteProtocol.sol";

/// @dev Use VoteProtocol directly in all new code.
contract Vote is VoteProtocol {}