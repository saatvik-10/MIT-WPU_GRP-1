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
}
