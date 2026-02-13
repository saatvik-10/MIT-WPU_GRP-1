import type { Context } from 'hono';
import { prisma } from '../../prisma';

export class Profile {
  async getProfile(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json('Unauthorized', 401);
    }

    try {
      const profile = await prisma.user.findUnique({
        where: {
          id: userId,
        },
        select: {
          name: true,
          email: true,
          phone: true,
          dob: true,
          gender: true,
          profileImageUrl: true,
          level: true,
        },
      });

      if (!profile) {
        return ctx.json('User not found', 404);
      }

      return ctx.json(profile, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Error fetching profile', 500);
    }
  }

  async getUserInterests(ctx: Context) {
    const userId = ctx.get('userId');
    const type = ctx.req.query('type') as 'DOMAIN' | 'PREFERENCE' | undefined;

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (type && type !== 'DOMAIN' && type !== 'PREFERENCE') {
      return ctx.json(
        { error: 'Invalid type. Must be DOMAIN or PREFERENCE' },
        400,
      );
    }

    try {
      const userInterests = await prisma.userInterest.findMany({
        where: {
          userId,
          ...(type && {
            interest: {
              type,
            },
          }),
        },
        include: {
          interest: true,
        },
      });

      const interests = userInterests.map((ui) => ui.interest);
      return ctx.json(interests, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error fetching interests' }, 500);
    }
  }

  async deleteUserInterest(ctx: Context) {
    const userId = ctx.get('userId');
    const interestId = ctx.req.param('interestId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!interestId) {
      return ctx.json({ error: 'Interest ID is required' }, 400);
    }

    try {
      await prisma.userInterest.deleteMany({
        where: {
          userId,
          interestId,
        },
      });

      return ctx.json({ message: 'Interest removed successfully' }, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error removing interest' }, 500);
    }
  }
}
