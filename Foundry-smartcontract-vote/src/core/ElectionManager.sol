// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ElectionManager = alias for ElectionFactory (same contract, different name)
import {ElectionFactory} from "./ElectionFactory.sol";

/// @dev Use ElectionFactory directly in all new code.
contract ElectionManagerCore is ElectionFactory {}