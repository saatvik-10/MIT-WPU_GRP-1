import { z } from 'zod';

export const progressSchema = z.object({
  xpEarned: z.number(),
  streakIncrement: z.number(),
  progressIncrement: z.float32(),
});

export type ProgressType = z.infer<typeof progressSchema>;
