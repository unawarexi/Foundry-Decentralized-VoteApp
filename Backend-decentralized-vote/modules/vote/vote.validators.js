// ============================================================================
// VoteSecure — Vote Validators
// ============================================================================

import { z } from "zod";

export const castVoteSchema = z.object({
  electionId: z.string().uuid(),
  candidateId: z.string().uuid(),
  nullifierHash: z.string().regex(/^0x[a-fA-F0-9]{64}$/, "Invalid nullifier hash format"),
  zkProof: z.string().optional(), // ZK proof bytes (base64 or hex)
  feeToken: z.enum(["USDT", "USDC", "ETH"]).default("USDT"),
  txHash: z.string().regex(/^0x[a-fA-F0-9]{64}$/, "Invalid tx hash").optional(),
});

export const hasVotedSchema = z.object({
  electionId: z.string().uuid(),
});
