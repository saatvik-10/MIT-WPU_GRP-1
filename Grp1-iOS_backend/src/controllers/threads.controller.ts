import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { followSchema } from '../validators/follow.validator';

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

  async updateFollow(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = followSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const { followingId } = data.data;

    if (userId === followingId) {
      return ctx.json({ error: 'You cannot follow yourself' }, 400);
    }

    try {
      const targetUser = await prisma.user.findUnique({
        where: {
          id: followingId,
        },
        select: {
          id: true,
        },
      });

      if (!targetUser) {
        return ctx.json({ error: 'User not found' }, 404);
      }

      const existingFollow = await prisma.follow.findUnique({
        where: {
          followerId_followingId: {
            followerId: userId,
            followingId,
          },
        },
      });

      let action: 'followed' | 'unfollowed' = 'followed';

      if (existingFollow) {
        await prisma.follow.delete({
          where: {
            followerId_followingId: {
              followerId: userId,
              followingId,
            },
          },
        });
        action = 'unfollowed';
      } else {
        await prisma.follow.create({
          data: {
            followerId: userId,
            followingId,
          },
        });
      }

      const [followersCount, followingCount] = await Promise.all([
        prisma.follow.count({
          where: {
            followingId,
          },
        }),
        prisma.follow.count({
          where: {
            followerId: userId,
          },
        }),
      ]);

      return ctx.json(
        {
          action,
          followersCount,
          followingCount,
        },
        200,
      );
    } catch (err) {
      console.error('Error updating followers count:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}

/**
 * add follow / unfollow on click in the three dots menu section
 * user profile -> image, posts, followers, following, all the posts
 * draft -> post title, tags, images, description, save draft which shows the saved ones and post is creation
 * show list of all followers
 * show list of all following
 */
