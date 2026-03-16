import type { Context } from 'hono';
import { prisma } from '../../prisma';

export class Threads {
  async getForYouThreads(ctx: Context) {
    try {
      const threads = await prisma.thread.findMany();
      return ctx.json(threads);
    } catch (err) {
      console.error('Error fetching progress:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getFollowingThreads(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const followingUsers = await prisma.follow.findMany({
        where: {
          followerId: userId,
        },
        select: {
          followingId: true,
        },
      });

      const followingIds = followingUsers.map((f) => f.followingId);

      const threads = await prisma.thread.findMany({
        where: {
          userId: {
            in: followingIds,
          },
        },
        include: {
          user: true,
          likes: true,
          comments: true,
          shares: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return ctx.json(threads);
    } catch (err) {
      console.error('Error fetching following threads:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}

/**
 * get all threads
 * get all follow waale threads
 * add threads bookmark
 * add follow / unfollow on click in the three dots menu section
 * user profile -> image, posts, followers, following, all the posts
 * draft -> post title, tags, images, description, save draft which shows the saved ones and post is creation
 * show list of all followers
 * show list of all following
 */
