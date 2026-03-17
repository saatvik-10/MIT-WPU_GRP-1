import { z } from 'zod';

export const createBookmarkFolderSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, 'Folder name is required')
    .max(80, 'Folder name is too long'),
});

export const createBookmarkSchema = z.object({
  folderId: z.string().trim().min(1, 'folderId is required'),
  title: z.string().trim().min(1, 'title is required').max(200),
  url: z.string().trim().url('url must be a valid URL'),
  imageUrl: z.string().trim().url('imageUrl must be a valid URL').optional(),
  description: z.string().trim().optional(),
  sourceType: z.enum(['ARTICLE', 'THREADS']),
});

export type CreateBookmarkFolderType = z.infer<typeof createBookmarkFolderSchema>;
export type CreateBookmarkType = z.infer<typeof createBookmarkSchema>;