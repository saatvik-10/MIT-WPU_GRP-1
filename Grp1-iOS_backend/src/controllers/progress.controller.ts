import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { progressSchema } from '../validators/progress.validator';

export class UserProgress {
  async updateProgress(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json('Unauthorized', 401);
    }

    try {
      const data = progressSchema.safeParse(await ctx.req.json());

      if (!data.success) {
        return ctx.json('Invalid Input', 422);
      }

      const progress = await prisma.userProgress.upsert({
        where: {
          id: userId,
        },
        update: {
          currentStreak: data.data.streakIncrement
            ? { increment: data.data.streakIncrement }
            : undefined,
        },
        create: {
          userId,
          currentStreak: data.data.streakIncrement ?? 0,
        },
      });

      return ctx.json({ message: 'Progress updated', progress }, 200);
    } catch (error) {
      console.error('Error updating progress:', error);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getUserProgress(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json('Unauthorized', 401);
    }

    try {
      const progress = await prisma.userProgress.findUnique({
        where: { userId },
      });

      if (!progress) {
        return ctx.json({ error: 'User progress not found' }, 404);
      }

      return ctx.json(progress, 200);
    } catch (error) {
      console.error('Error fetching progress:', error);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}
