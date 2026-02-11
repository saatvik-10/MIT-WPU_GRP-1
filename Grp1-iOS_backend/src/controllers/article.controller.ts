import type { Context } from 'hono';
import { prisma } from '../../prisma';

export class Articles {
  async chatQuestion(ctx: Context) {}

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
