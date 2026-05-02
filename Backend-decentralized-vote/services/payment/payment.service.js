// ============================================================================
// VoteSecure — Payment Service
// Crypto payment verification for vote fee escrow (USDT/USDC/ETH)
// ============================================================================

import { ethers } from "ethers";
import { env } from "../../config/env.config.js";
import { createLogger } from "../../logs/logger.js";
import { PaymentConfig } from "../../config/constants.js";
import { getProvider } from "./blockchain.service.js";
import { prisma } from "../../config/prisma.js";

const log = createLogger("Payment");

// ERC-20 minimal ABI for USDT/USDC
const ERC20_ABI = [
  "function balanceOf(address owner) external view returns (uint256)",
  "function allowance(address owner, address spender) external view returns (uint256)",
  "function transfer(address to, uint256 amount) external returns (bool)",
  "function decimals() external view returns (uint8)",
  "event Transfer(address indexed from, address indexed to, uint256 value)",
];

const ESCROW_ABI = [
  "function hasPaid(bytes32 electionId, bytes32 nullifier) external view returns (bool)",
  "function getBalance(bytes32 electionId) external view returns (uint256)",
  "event FeePaid(bytes32 indexed electionId, address indexed voter, bytes32 nullifier, uint256 amount)",
];

let escrowContract = null;
const tokenContracts = {};

// ============================================================================
// INITIALIZATION
// ============================================================================

export function initPaymentService() {
  const provider = getProvider();
  if (!provider) {
    log.warn("Provider not ready — payment service in mock mode");
    return;
  }

  if (env.CONTRACT_VOTE_FEE_ESCROW) {
    escrowContract = new ethers.Contract(env.CONTRACT_VOTE_FEE_ESCROW, ESCROW_ABI, provider);
    log.info("Escrow contract initialized");
  }

  if (env.USDT_CONTRACT_ADDRESS) {
    tokenContracts.USDT = new ethers.Contract(env.USDT_CONTRACT_ADDRESS, ERC20_ABI, provider);
  }

  if (env.USDC_CONTRACT_ADDRESS) {
    tokenContracts.USDC = new ethers.Contract(env.USDC_CONTRACT_ADDRESS, ERC20_ABI, provider);
  }

  log.success("Payment service initialized");
}

// ============================================================================
// FEE VERIFICATION
// Polls the escrow contract to verify that payment is confirmed on-chain
// ============================================================================

export async function verifyVoteFeePayment({ electionId, nullifierHash, expectedAmountWei, timeoutMs = 300000 }) {
  if (!escrowContract) {
    log.warn("Escrow contract not ready — skipping fee verification (dev mode)");
    return { paid: true, mock: true };
  }

  const electionBytes32 = ethers.encodeBytes32String(electionId.slice(0, 31));
  const nullifierBytes32 = ethers.zeroPadBytes(nullifierHash, 32);

  const deadline = Date.now() + timeoutMs;
  const pollInterval = 5000;

  while (Date.now() < deadline) {
    const paid = await escrowContract.hasPaid(electionBytes32, nullifierBytes32);
    if (paid) {
      log.info(`Fee confirmed for nullifier ${nullifierHash}`);
      return { paid: true, mock: false };
    }
    await new Promise((r) => setTimeout(r, pollInterval));
  }

  throw new Error("Vote fee payment not confirmed within timeout");
}

// ============================================================================
// WATCH FOR PAYMENT EVENTS (used by webhook/worker)
// ============================================================================

export function listenForFeePaidEvent(electionId, callback) {
  if (!escrowContract) return;

  const electionBytes32 = ethers.encodeBytes32String(electionId.slice(0, 31));

  const filter = escrowContract.filters.FeePaid(electionBytes32);

  escrowContract.on(filter, (electionId, voter, nullifier, amount, event) => {
    callback({
      electionId: ethers.decodeBytes32String(electionId),
      voter,
      nullifier: ethers.hexlify(nullifier),
      amount: amount.toString(),
      txHash: event.log.transactionHash,
      blockNumber: Number(event.log.blockNumber),
    });
  });

  log.info(`Listening for FeePaid events on election ${electionId}`);
}

// ============================================================================
// TRANSACTION RECORD
// ============================================================================

export async function recordTransaction({
  userId,
  electionId,
  type,
  amount,
  token,
  txHash,
  blockNumber,
  fromAddress,
  toAddress,
  status = "CONFIRMED",
}) {
  return prisma.walletTransaction.upsert({
    where: { txHash: txHash || `pending-${userId}-${Date.now()}` },
    update: { status, blockNumber: blockNumber ? BigInt(blockNumber) : undefined },
    create: {
      userId,
      electionId,
      type,
      amount,
      token,
      txHash,
      blockNumber: blockNumber ? BigInt(blockNumber) : undefined,
      fromAddress,
      toAddress,
      status,
    },
  });
}

// ============================================================================
// SUPPORTED TOKEN DECIMALS
// ============================================================================

const TOKEN_DECIMALS = { USDT: 6, USDC: 6, ETH: 18 };

export function amountToWei(amountHumanReadable, token) {
  const decimals = TOKEN_DECIMALS[token] ?? 18;
  return ethers.parseUnits(String(amountHumanReadable), decimals);
}

export function weiToAmount(wei, token) {
  const decimals = TOKEN_DECIMALS[token] ?? 18;
  return ethers.formatUnits(BigInt(wei), decimals);
}

export function isSupportedToken(token) {
  return PaymentConfig.SUPPORTED_TOKENS.includes(token);
}
