// ============================================================================
// VoteSecure — Region Module
// ============================================================================

import { z } from "zod";

export const createRegionSchema = z.object({
  name: z.string().min(2).max(100),
  countryCode: z.string().length(2, "Must be ISO 3166-1 alpha-2"),
  stateCode: z.string().max(10).optional(),
  level: z.enum(["NATIONAL", "STATE", "LOCAL"]),
  geoJson: z.any().optional(),
});

export const updateRegionSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  isActive: z.boolean().optional(),
  geoJson: z.any().optional(),
});

export const assignVoterSchema = z.object({
  userId: z.string().uuid(),
});
