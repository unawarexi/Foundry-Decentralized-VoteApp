// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Legacy alias — ElectionFactory is the production contract
import {ElectionFactory} from "./core/ElectionFactory.sol";

/// @dev Use ElectionFactory directly in all new code.
contract ElectionManager is ElectionFactory {}