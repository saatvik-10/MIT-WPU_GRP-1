import { z } from 'zod';

export const createThreadSchema = z.object({
  title: z.string().trim().min(1, 'title is required').max(200),
  description: z.string().trim().min(1, 'description is required'),
  tags: z.array(z.string()).default([]),
});

// export const updateThreadSchema = z.object({
//   title: z.string().trim().min(1, 'title is required').max(200).optional(),
//   description: z.string().trim().min(1, 'description is required').optional(),
//   imageName: z.string().trim().optional(),
//   tags: z.array(z.string()).optional(),
// });

export const threadDraftSchema = z.object({
  threadId: z.string().trim().min(1, 'threadId is required'),
  title: z.string().trim().min(1, 'title is required').max(200),
  description: z.string().trim().min(1, 'description is required'),
  tags: z.array(z.string()).default([]),
});

export const updateThreadDraftSchema = z.object({
  title: z.string().trim().min(1, 'title is required').max(200).optional(),
  description: z.string().trim().min(1, 'description is required').optional(),
  imageName: z.string().trim().optional(),
  tags: z.array(z.string()).optional(),
});

export const threadCommentSchema = z.object({
  threadId: z.string().trim().min(1, 'threadId is required'),
  description: z.string().trim().min(1, 'description is required'),
});

export const threadLikeSchema = z.object({
  threadId: z.string().trim().min(1, 'threadId is required'),
});

export const followSchema = z.object({
  followingId: z.string().trim().min(1, 'followingId is required'),
});

export type CreateThreadType = z.infer<typeof createThreadSchema>;
// export type UpdateThreadType = z.infer<typeof updateThreadSchema>;
export type ThreadDraftType = z.infer<typeof threadDraftSchema>;
export type UpdateThreadDraftType = z.infer<typeof updateThreadDraftSchema>;
export type ThreadCommentType = z.infer<typeof threadCommentSchema>;
export type ThreadLikeType = z.infer<typeof threadLikeSchema>;
export type FollowType = z.infer<typeof followSchema>;
