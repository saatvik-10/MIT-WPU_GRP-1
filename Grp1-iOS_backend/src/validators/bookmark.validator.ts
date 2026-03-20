import { z } from 'zod';

export const createBookmarkSchema = z.object({
  folderId: z.string().trim().min(1, 'folderId is required'),
  title: z.string().trim().min(1, 'title is required').max(200),
  url: z.string().trim().url('Invalid URL'),
  sourceType: z.string().trim().min(1, 'sourceType is required'),
  imageUrl: z.string().trim().min(1, 'imageUrl is required'),
  description: z.string().trim().min(1, 'description is required'),
});

export const createBookmarkFolderSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Folder name is required')
    .max(80, 'Folder name is too long'),
});

export const createBookmarkedArticleSchema = z.object({
  folderId: z.string().trim().min(1, 'folderId is required'),
  title: z.string().trim().min(1, 'title is required').max(200),
  description: z.string().trim().min(1, 'description is required'),
  imageName: z.string().trim().min(1, 'imageName is required'),
  source: z.string().trim().min(1, 'source is required'),
  overview: z.array(z.string()).default([]),
  keyTakeaways: z.array(z.string()).default([]),
  jargons: z.array(z.string()).default([]),
  date: z.string().trim().min(1, 'date is required'),
});

export const createBookmarkedThreadSchema = z.object({
  folderId: z.string().trim().min(1, 'folderId is required'),
  threadId: z.string().trim().min(1, 'threadId is required'),
  title: z.string().trim().min(1, 'title is required').max(200),
  description: z.string().trim().min(1, 'description is required'),
  imageName: z.string().trim().min(1, 'imageName is required'),
  tags: z.array(z.string()).default([]),
});

export type CreateBookmarkType = z.infer<typeof createBookmarkSchema>;
export type CreateBookmarkFolderType = z.infer<typeof createBookmarkFolderSchema>;
export type CreateBookmarkedArticleType = z.infer<typeof createBookmarkedArticleSchema>;
export type CreateBookmarkedThreadType = z.infer<typeof createBookmarkedThreadSchema>;