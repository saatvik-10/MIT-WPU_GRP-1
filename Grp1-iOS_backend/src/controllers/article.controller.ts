import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { articleQnASchema } from '../validators/article.validator';

export class Articles {
  async postChatQuestion(ctx: Context) {
    const data = articleQnASchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json('Invalid Input', 422);
    }
    try {
      const qna = await prisma.articleSummaryQnA.create({
        data: {
          question: data.data.question,
          answer: data.data.answer,
        },
      });

      return ctx.json(qna.id, 201);
    } catch (err: any) {
      console.log(err);
      return ctx.json('Err posting question', err);
    }
  }

  async getChatQuestion(ctx: Context) {
    try {
      const data = await prisma.articleSummaryQnA.findFirst({
        orderBy: { createdAt: 'desc' },
        take: 1,
      });

      return ctx.json(data, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Err fetching qna', 500);
    }
  }

  async summaryQuiz(ctx: Context) {}

  async allChatQuestions(ctx: Context) {
    try {
      const data = await prisma.articleSummaryQnA.findMany();

      return ctx.json(data, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Err fetching qna', 500);
    }
  }
}
