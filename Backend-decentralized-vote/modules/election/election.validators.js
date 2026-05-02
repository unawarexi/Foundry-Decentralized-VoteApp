// ============================================================================
// VoteSecure — Election Validators
// ============================================================================

import { z } from "zod";

const ISO_DATE = z.string().datetime({ message: "Must be a valid ISO 8601 datetime" });

export const createElectionSchema = z.object({
  title: z.string().min(5).max(200),
  description: z.string().max(5000).optional(),
  type: z.enum([
    "SCHOOL", "UNIVERSITY", "COMPANY", "LOCAL_GOVERNMENT",
    "MAYORAL", "GUBERNATORIAL", "NATIONAL", "UNION", "COOPERATIVE", "CUSTOM",
  ]),
  regionId: z.string().uuid(),
  startDate: ISO_DATE,
  endDate: ISO_DATE,
  registrationEnd: ISO_DATE.optional(),
  voteFeeCents: z.number().int().min(50).max(10000).default(100),
  feeToken: z.enum(["USDT", "USDC", "ETH"]).default("USDT"),
  minCandidates: z.number().int().min(2).default(2),
  maxCandidates: z.number().int().min(2).max(500).default(100),
}).refine((d) => new Date(d.endDate) > new Date(d.startDate), {
  message: "endDate must be after startDate",
  path: ["endDate"],
});

export const updateElectionPhaseSchema = z.object({
  status: z.enum(["ACTIVE", "PAUSED", "TALLYING", "FINALIZED", "CANCELLED"]),
  cancelReason: z.string().max(500).optional(),
});

export const listElectionsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(["DRAFT", "PENDING", "ACTIVE", "PAUSED", "TALLYING", "FINALIZED", "CANCELLED"]).optional(),
  type: z.string().optional(),
  regionId: z.string().uuid().optional(),
  search: z.string().max(100).optional(),
}).optional();
