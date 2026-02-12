import { z } from 'zod';

export const articleQnASchema = z.object({
  question: z.string().min(1, 'Question is required'),
  answer: z.string().min(1, 'Answer is required'),
});

export type ArticleQnAType = z.infer<typeof articleQnASchema>;
