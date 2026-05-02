import { z } from "zod";

export const reportFraudSchema = z.object({
  flaggedUserId: z.string().uuid(),
  electionId: z.string().uuid().optional(),
  description: z.string().min(20).max(2000),
  evidenceHash: z.string().optional(),
});

export const resolveReportSchema = z.object({
  confirmed: z.boolean(),
  resolution: z.string().min(10).max(1000),
});
