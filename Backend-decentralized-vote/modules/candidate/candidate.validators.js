// ============================================================================
// VoteSecure — Candidate Validators
// ============================================================================

import { z } from "zod";

export const registerCandidateSchema = z.object({
  electionId: z.string().uuid(),
  partyId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
  profileBio: z.string().max(5000).optional(),
  manifestoUrl: z.string().url().optional(),
  achievements: z.array(z.object({
    title: z.string(),
    date: z.string().optional(),
    verifiedUrl: z.string().url().optional(),
  })).optional(),
  milestones: z.array(z.object({
    milestone: z.string(),
    targetDate: z.string().optional(),
    status: z.enum(["PENDING", "IN_PROGRESS", "COMPLETED"]).optional(),
  })).optional(),
  lifeSummary: z.string().max(2000).optional(),
  payoutAddress: z.string().regex(/^0x[a-fA-F0-9]{40}$/).optional(),
});

export const updateCandidateSchema = z.object({
  profileBio: z.string().max(5000).optional(),
  manifestoUrl: z.string().url().optional(),
  achievements: z.array(z.any()).optional(),
  milestones: z.array(z.any()).optional(),
  lifeSummary: z.string().max(2000).optional(),
  payoutAddress: z.string().regex(/^0x[a-fA-F0-9]{40}$/).optional(),
});

export const approveCandidateSchema = z.object({
  candidateId: z.string().uuid(),
  action: z.enum(["approve", "reject", "disqualify"]),
  reason: z.string().max(500).optional(),
});
