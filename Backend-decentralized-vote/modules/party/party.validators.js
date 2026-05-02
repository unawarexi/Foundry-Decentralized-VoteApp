// ============================================================================
// VoteSecure — Party Module (validators, service, controller, routes)
// ============================================================================

// validators
import { z } from "zod";

export const createPartySchema = z.object({
  name: z.string().min(2).max(100),
  ideology: z.string().max(200).optional(),
  manifestoUrl: z.string().url().optional(),
  foundedYear: z.number().int().min(1800).max(new Date().getFullYear()).optional(),
  logoUrl: z.string().url().optional(),
});

export const updatePartySchema = z.object({
  name: z.string().min(2).max(100).optional(),
  ideology: z.string().max(200).optional(),
  manifestoUrl: z.string().url().optional(),
  logoUrl: z.string().url().optional(),
});
