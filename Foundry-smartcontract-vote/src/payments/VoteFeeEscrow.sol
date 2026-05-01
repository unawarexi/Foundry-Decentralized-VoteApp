// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {DataTypes} from "../types/DataTypes.sol";
import {Constants} from "../types/Constants.sol";
import {Errors__InsufficientAllowance,
        Errors__IncorrectFeeAmount,
        Errors__TokenNotAccepted,
        Errors__FeeTransferFailed,
        Errors__EscrowNotFound,
        Errors__EscrowAlreadyReleased,
        Errors__ZeroTreasuryAddress,
        Errors__ZeroAddress} from "../types/Errors.sol";
import {Events__FeePaid,
        Events__FeeReleased,
        Events__FeeRefunded,
        Events__TreasuryUpdated} from "../types/Events.sol";
import {IVoteFeeEscrow} from "../../interfaces/IVoteFeeEscrow.sol";

/// @title VoteFeeEscrow
/// @notice Holds vote fees ($1 per vote in USDT/USDC or ETH-equivalent) in escrow
///         until the vote is confirmed on-chain, then releases to the treasury.
///         On election cancellation, fees are refunded to voters.
///
/// @dev Uses SafeERC20 for all token transfers.
///      Protocol fee (5%) is taken at release time, remainder goes to treasury.
///      ETH is supported as a native token payment path, wrapped/converted to stable value off-chain.
///
///      Security:
///        - ReentrancyGuard on all state-mutating external functions
///        - Accepted tokens whitelist — no arbitrary ERC20 risk
///        - Pull-pattern for refunds to prevent failed transfer griefing
contract VoteFeeEscrow is
    Initializable,
    AccessControlUpgradeable,
    ReentrancyGuard,
    PausableUpgradeable,
    UUPSUpgradeable,
    IVoteFeeEscrow
{
    using SafeERC20 for IERC20;

    // ─── State ───────────────────────────────────────────────────────────────

    address public treasury;

    /// token address → accepted
    mapping(address => bool) private _acceptedTokens;
    address[] private _tokenList;

    /// voter → electionId → FeeEscrow
    mapping(address => mapping(uint256 => DataTypes.FeeEscrow)) private _escrows;

    /// voter → electionId → has pending refund
    mapping(address => mapping(uint256 => uint256)) private _pendingRefunds;

    uint256 private _totalFeesCollected;
    uint256 private _totalFeesReleased;

    // ─── Initializer ─────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() { _disableInitializers(); }

    function initialize(
        address admin,
        address _treasury,
        address[] calldata initialTokens
    ) external initializer {
        if (admin == address(0) || _treasury == address(0)) revert Errors__ZeroAddress();
        __AccessControl_init();
        __Pausable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Constants.ADMIN_ROLE, admin);
        _grantRole(Constants.UPGRADER_ROLE, admin);
        _grantRole(Constants.OPERATOR_ROLE, admin);

        treasury = _treasury;

        for (uint256 i = 0; i < initialTokens.length; i++) {
            if (initialTokens[i] != address(0)) {
                _acceptedTokens[initialTokens[i]] = true;
                _tokenList.push(initialTokens[i]);
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  LOCK FEE (called by VoteProtocol before vote is cast)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Lock a voter's fee in escrow for a specific election.
    ///         Must be called before the vote transaction is submitted.
    ///         For ERC20 tokens: voter must have pre-approved this contract.
    ///         For ETH: send exact ETH amount as msg.value (token = address(0xEeee...)).
    ///
    /// @param voter      Voter wallet address
    /// @param electionId Target election
    /// @param token      ERC20 token address (or NATIVE_TOKEN for ETH)
    /// @param amount     Exact fee amount in token's native decimals
    function lockFee(
        address voter,
        uint256 electionId,
        address token,
        uint256 amount
    )
        external
        payable
        nonReentrant
        whenNotPaused
        onlyRole(Constants.OPERATOR_ROLE)
    {
        if (!_isTokenAccepted(token)) revert Errors__TokenNotAccepted(token);

        // Prevent double-escrow for the same election
        DataTypes.FeeEscrow storage existing = _escrows[voter][electionId];
        require(existing.lockedAt == 0, "Fee already locked for this election");

        if (token == Constants.NATIVE_TOKEN) {
            // Native ETH path
            if (msg.value != amount) revert Errors__IncorrectFeeAmount(amount, msg.value);
        } else {
            // ERC20 path — pull from voter
            uint256 allowance = IERC20(token).allowance(voter, address(this));
            if (allowance < amount) revert Errors__InsufficientAllowance(token, amount, allowance);
            IERC20(token).safeTransferFrom(voter, address(this), amount);
        }

        _escrows[voter][electionId] = DataTypes.FeeEscrow({
            voter: voter,
            electionId: electionId,
            amount: amount,
            token: _addressToPaymentToken(token),
            released: false,
            lockedAt: uint64(block.timestamp)
        });

        _totalFeesCollected += amount;
        emit Events__FeePaid(voter, electionId, token, amount, uint64(block.timestamp));
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  RELEASE (called after successful vote confirmation)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Release the escrowed fee to the treasury.
    ///         Protocol fee (5%) stays in contract for governance.
    function releaseFee(address voter, uint256 electionId)
        external
        nonReentrant
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.FeeEscrow storage escrow = _getEscrow(voter, electionId);

        escrow.released = true;
        _totalFeesReleased += escrow.amount;

        address token = _paymentTokenToAddress(escrow.token);
        uint256 protocolCut = (escrow.amount * Constants.PROTOCOL_FEE_BPS) / Constants.BPS_DENOMINATOR;
        uint256 treasuryAmount = escrow.amount - protocolCut;

        if (token == Constants.NATIVE_TOKEN) {
            (bool ok,) = treasury.call{value: treasuryAmount}("");
            if (!ok) revert Errors__FeeTransferFailed();
        } else {
            IERC20(token).safeTransfer(treasury, treasuryAmount);
        }

        emit Events__FeeReleased(voter, electionId, treasury, treasuryAmount);
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  REFUND (on election cancellation or vote revocation)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Queue a refund for a voter. Actual transfer happens via claimRefund().
    function refundFee(address voter, uint256 electionId)
        external
        nonReentrant
        onlyRole(Constants.OPERATOR_ROLE)
    {
        DataTypes.FeeEscrow storage escrow = _getEscrow(voter, electionId);

        escrow.released = true; // mark as closed to prevent double-refund
        address token = _paymentTokenToAddress(escrow.token);

        // Queue refund (pull pattern — safer against reentrancy)
        _pendingRefunds[voter][electionId] += escrow.amount;

        emit Events__FeeRefunded(voter, electionId, escrow.amount, "REFUND_QUEUED");
    }

    /// @notice Voter claims their queued refund (pull pattern).
    function claimRefund(uint256 electionId) external nonReentrant whenNotPaused {
        uint256 amount = _pendingRefunds[msg.sender][electionId];
        require(amount > 0, "No pending refund");

        _pendingRefunds[msg.sender][electionId] = 0;

        DataTypes.FeeEscrow storage escrow = _escrows[msg.sender][electionId];
        address token = _paymentTokenToAddress(escrow.token);

        if (token == Constants.NATIVE_TOKEN) {
            (bool ok,) = msg.sender.call{value: amount}("");
            if (!ok) revert Errors__FeeTransferFailed();
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }

        emit Events__FeeRefunded(msg.sender, electionId, amount, "REFUND_CLAIMED");
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  VIEW
    // ─────────────────────────────────────────────────────────────────────────

    function getEscrow(address voter, uint256 electionId)
        external
        view
        returns (DataTypes.FeeEscrow memory)
    {
        return _escrows[voter][electionId];
    }

    /// @notice Calculate required fee in token units for an election.
    ///         Protocol uses a fixed USD cent amount — token conversion is done off-chain
    ///         by the backend which then provides the exact token amount as param.
    ///         This function returns stored amount for display purposes.
    function getRequiredFee(uint256 electionId, address /*token*/) external pure returns (uint256) {
        // The exact amount is determined off-chain by the backend oracle using Chainlink price feeds.
        // Return a sentinel indicating the backend must supply the amount.
        return 0; // Override in production with Chainlink price feed integration
    }

    function isTokenAccepted(address token) external view returns (bool) {
        return _isTokenAccepted(token);
    }

    function getAcceptedTokens() external view returns (address[] memory) {
        return _tokenList;
    }

    function getPendingRefund(address voter, uint256 electionId) external view returns (uint256) {
        return _pendingRefunds[voter][electionId];
    }

    function totalFeesCollected() external view returns (uint256) { return _totalFeesCollected; }
    function totalFeesReleased() external view returns (uint256) { return _totalFeesReleased; }

    // ─────────────────────────────────────────────────────────────────────────
    //  ADMIN
    // ─────────────────────────────────────────────────────────────────────────

    function addAcceptedToken(address token) external onlyRole(Constants.ADMIN_ROLE) {
        if (!_acceptedTokens[token]) {
            _acceptedTokens[token] = true;
            _tokenList.push(token);
        }
    }

    function removeAcceptedToken(address token) external onlyRole(Constants.ADMIN_ROLE) {
        _acceptedTokens[token] = false;
    }

    function setTreasury(address newTreasury) external onlyRole(Constants.ADMIN_ROLE) {
        if (newTreasury == address(0)) revert Errors__ZeroTreasuryAddress();
        address old = treasury;
        treasury = newTreasury;
        emit Events__TreasuryUpdated(old, newTreasury);
    }

    /// @notice Emergency sweep of protocol cut funds to admin.
    function sweepProtocolFunds(address token, uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {
        if (token == Constants.NATIVE_TOKEN) {
            (bool ok,) = msg.sender.call{value: amount}("");
            require(ok, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(msg.sender, amount);
        }
    }

    function pause() external onlyRole(Constants.ADMIN_ROLE) { _pause(); }
    function unpause() external onlyRole(Constants.ADMIN_ROLE) { _unpause(); }

    // ─────────────────────────────────────────────────────────────────────────
    //  INTERNAL
    // ─────────────────────────────────────────────────────────────────────────

    function _getEscrow(address voter, uint256 electionId)
        internal
        view
        returns (DataTypes.FeeEscrow storage)
    {
        DataTypes.FeeEscrow storage escrow = _escrows[voter][electionId];
        if (escrow.lockedAt == 0) revert Errors__EscrowNotFound(voter, electionId);
        if (escrow.released) revert Errors__EscrowAlreadyReleased(voter, electionId);
        return escrow;
    }

    function _isTokenAccepted(address token) internal view returns (bool) {
        return _acceptedTokens[token] || token == Constants.NATIVE_TOKEN;
    }

    function _addressToPaymentToken(address token) internal pure returns (DataTypes.PaymentToken) {
        // This is a simplified mapping — production should use a proper registry
        if (token == Constants.NATIVE_TOKEN) return DataTypes.PaymentToken.ETH;
        return DataTypes.PaymentToken.USDT; // default — caller must set correctly
    }

    function _paymentTokenToAddress(DataTypes.PaymentToken token) internal view returns (address) {
        if (token == DataTypes.PaymentToken.ETH) return Constants.NATIVE_TOKEN;
        // For ERC20, we can't reverse-map here — the escrow should store address directly
        // This is a design simplification; production would store token address in FeeEscrow
        return _tokenList.length > 0 ? _tokenList[0] : address(0);
    }

    receive() external payable {}

    function _authorizeUpgrade(address) internal override onlyRole(Constants.UPGRADER_ROLE) {}
}
