// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Legacy alias — IdentityRegistry is the production contract
import {IdentityRegistry} from "./identity/IdentityRegistry.sol";

/// @dev Use IdentityRegistry directly in all new code.
contract VoterRegistry is IdentityRegistry {}