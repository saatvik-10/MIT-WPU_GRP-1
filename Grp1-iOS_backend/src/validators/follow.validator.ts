import { z } from 'zod';

export const followSchema = z.object({
	followingId: z.string().trim().min(1, 'followingId is required'),
});

export type FollowType = z.infer<typeof followSchema>;