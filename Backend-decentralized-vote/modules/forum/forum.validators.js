import { z } from "zod";

export const createPostSchema = z.object({
  electionId: z.string().uuid(),
  candidateId: z.string().uuid().optional(),
  content: z.string().min(10).max(1000),
});

export const answerPostSchema = z.object({
  candidateId: z.string().uuid(),
  content: z.string().min(10).max(5000),
});

export const voteOnPostSchema = z.object({
  value: z.number().int().refine((v) => v === 1 || v === -1, { message: "Must be 1 or -1" }),
});
