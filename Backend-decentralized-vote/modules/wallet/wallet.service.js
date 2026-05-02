// ============================================================================
// VoteSecure — Wallet / Transaction Service
// ============================================================================

import { prisma } from "../../config/prisma.js";
import { AppError } from "../../middlewares/errorhandler.middleware.js";
import { HttpStatus, ErrorCodes, PaymentConfig } from "../../config/constants.js";
import { getProvider } from "../../services/blockchain/blockchain.service.js";
import { ethers } from "ethers";

const ERC20_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",
];

export async function getTransactionHistory({ userId, page = 1, limit = 20, type }) {
  const skip = (page - 1) * limit;
  const where = { userId };
  if (type) where.type = type;

  const [data, total] = await Promise.all([
    prisma.walletTransaction.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
    }),
    prisma.walletTransaction.count({ where }),
  ]);

  return { data, total, page, limit };
}

export async function getWalletBalance(walletAddress) {
  const provider = getProvider();

  const nativeBalance = await provider.getBalance(walletAddress);

  const tokens = await Promise.allSettled(
    Object.entries(PaymentConfig.TOKEN_ADDRESSES || {}).map(async ([symbol, address]) => {
      const contract = new ethers.Contract(address, ERC20_ABI, provider);
      const [balance, decimals] = await Promise.all([
        contract.balanceOf(walletAddress),
        contract.decimals(),
      ]);
      return {
        symbol,
        address,
        balance: ethers.formatUnits(balance, decimals),
        rawBalance: balance.toString(),
      };
    })
  );

  return {
    walletAddress,
    nativeBalance: ethers.formatEther(nativeBalance),
    tokens: tokens.filter((r) => r.status === "fulfilled").map((r) => r.value),
  };
}

export async function getMyBalance(userId) {
  const user = await prisma.user.findUnique({ where: { id: userId }, select: { walletAddress: true } });
  if (!user?.walletAddress) {
    throw new AppError("No wallet linked to account", HttpStatus.BAD_REQUEST, ErrorCodes.WALLET_NOT_CONNECTED);
  }
  return getWalletBalance(user.walletAddress);
}
