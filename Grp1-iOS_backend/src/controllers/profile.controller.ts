import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { editProfileSchema } from '../validators/user.validator';
import { r2Service } from '../services/r2.service';

export class Profile {
  async getUserProfile(ctx: Context) {
    const currentUserId = ctx.get('userId');
    const requestedUserId = ctx.req.param('userId');

    if (!currentUserId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!requestedUserId) {
      return ctx.json({ error: 'User ID is required' }, 400);
    }

    try {
      const profile = await prisma.user.findUnique({
        where: {
          id: requestedUserId,
        },
        select: {
          id: true,
          name: true,
          username: true,
          email: true,
          phone: true,
          dob: true,
          gender: true,
          profileImageUrl: true,
          level: true,
          _count: {
            select: {
              followers: true,
              following: true,
              thread: true,
            },
          },
        },
      });

      if (!profile) {
        return ctx.json({ error: 'User not found' }, 404);
      }

      let profileImagePresignedUrl = null;
      if (profile.profileImageUrl) {
        try {
          profileImagePresignedUrl = await r2Service.getPresignedUrl(
            profile.profileImageUrl,
          );
        } catch (err) {
          console.error('Failed to get presigned URL:', err);
          return ctx.json({ error: 'Error fetching user image' }, 500);
        }
      }

      const isFollowing =
        requestedUserId === currentUserId
          ? false
          : !!(await prisma.follow.findUnique({
            where: {
              followerId_followingId: {
                followerId: currentUserId,
                followingId: requestedUserId,
              },
            },
          }));

      return ctx.json(
        {
          ...profile,
          profileImageUrl: profileImagePresignedUrl,
          isSelf: requestedUserId === currentUserId,
          isFollowing,
        },
        200,
      );
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error fetching user profile' }, 500);
    }
  }

  async getFollowers(ctx: Context) {
    const currentUserId = ctx.get('userId');
    const requestedUserId = ctx.req.param('userId');

    if (!currentUserId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!requestedUserId) {
      return ctx.json({ error: 'User ID is required' }, 400);
    }

    try {
      const followers = await prisma.follow.findMany({
        where: {
          followingId: requestedUserId,
        },
        select: {
          follower: {
            select: {
              id: true,
              name: true,
              username: true,
              profileImageUrl: true,
              level: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const followersWithUrls = await Promise.all(
        followers.map(async (item) => {
          let profileImageUrl = item.follower.profileImageUrl;
          if (profileImageUrl) {
            try {
              profileImageUrl =
                await r2Service.getPresignedUrl(profileImageUrl);
            } catch (err) {
              console.error('Failed to get presigned URL for follower:', err);
            }
          }
          return {
            ...item.follower,
            profileImageUrl,
          };
        }),
      );

      return ctx.json(followersWithUrls, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error fetching followers' }, 500);
    }
  }

  async getFollowing(ctx: Context) {
    const currentUserId = ctx.get('userId');
    const requestedUserId = ctx.req.param('userId');

    if (!currentUserId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!requestedUserId) {
      return ctx.json({ error: 'User ID is required' }, 400);
    }

    try {
      const following = await prisma.follow.findMany({
        where: {
          followerId: requestedUserId,
        },
        select: {
          following: {
            select: {
              id: true,
              name: true,
              username: true,
              profileImageUrl: true,
              level: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const followingWithUrls = await Promise.all(
        following.map(async (item) => {
          let profileImageUrl = item.following.profileImageUrl;
          if (profileImageUrl) {
            try {
              profileImageUrl =
                await r2Service.getPresignedUrl(profileImageUrl);
            } catch (err) {
              console.error(
                'Failed to get presigned URL for following user:',
                err,
              );
            }
          }
          return {
            ...item.following,
            profileImageUrl,
          };
        }),
      );

      return ctx.json(followingWithUrls, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error fetching following users' }, 500);
    }
  }

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
          username: true,
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

      // ✅ FIXED: Generate presigned URL before returning — was returning raw S3 key
      let profileImageUrl: string | null = null;
      if (profile.profileImageUrl) {
        try {
          profileImageUrl = await r2Service.getPresignedUrl(
            profile.profileImageUrl,
          );
        } catch (err) {
          console.error('[Profile] Failed to get presigned URL:', err);
        }
      }

      return ctx.json({ ...profile, profileImageUrl }, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Error fetching profile', 500);
    }
  }

  async editProfile(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const body = await ctx.req.json();
    const data = editProfileSchema.safeParse(body);

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const { name, email, phone, dob, gender } = data.data;

    const updateData: Record<string, string> = {};
    if (name !== undefined) updateData.name = name;
    if (email !== undefined) updateData.email = email;
    if (phone !== undefined) updateData.phone = phone;
    if (dob !== undefined) updateData.dob = dob;
    if (gender !== undefined) updateData.gender = gender;

    if (Object.keys(updateData).length === 0) {
      return ctx.json({ error: 'No fields to update' }, 400);
    }

    try {
      const updatedUser = await prisma.user.update({
        where: { id: userId },
        data: updateData,
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          dob: true,
          gender: true,
        },
      });

      return ctx.json(updatedUser, 200);
    } catch (err) {
      console.error('Error updating profile:', err);
      if ((err as any).code === 'P2002') {
        return ctx.json({ error: 'Email already in use' }, 409);
      }
      return ctx.json({ error: 'Error updating profile' }, 500);
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

  async getAvailableInterests(ctx: Context) {
    const type = ctx.req.query('type') as 'DOMAIN' | 'PREFERENCE' | undefined;

    if (type && type !== 'DOMAIN' && type !== 'PREFERENCE') {
      return ctx.json(
        { error: 'Invalid type. Must be DOMAIN or PREFERENCE' },
        400,
      );
    }

    try {
      const interests = await prisma.interest.findMany({
        where: type ? { type } : {},
        orderBy: {
          name: 'asc',
        },
      });

      return ctx.json(interests, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error fetching available interests' }, 500);
    }
  }

  async addUserInterest(ctx: Context) {
    const userId = ctx.get('userId');
    const { interestId } = await ctx.req.json();

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!interestId) {
      return ctx.json({ error: 'Interest ID is required' }, 400);
    }

    try {
      const interest = await prisma.interest.findUnique({
        where: { id: interestId },
      });

      if (!interest) {
        return ctx.json({ error: 'Interest not found' }, 404);
      }

      const existing = await prisma.userInterest.findUnique({
        where: {
          userId_interestId: {
            userId,
            interestId,
          },
        },
      });

      if (existing) {
        return ctx.json({ error: 'Interest already added' }, 409);
      }

      const userInterest = await prisma.userInterest.create({
        data: {
          userId,
          interestId,
        },
        include: {
          interest: true,
        },
      });

      return ctx.json(userInterest.interest, 201);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error adding interest' }, 500);
    }
  }

  async finishOnboarding(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    try {
      await prisma.user.update({ where: { id: userId }, data: { hasOnboarding: true } });
      return ctx.json({ message: 'Onboarding completed' }, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Database error' }, 500);
    }
  }

  async updateLevel(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    
    const body = await ctx.req.json();
    const level = body.level;
    
    if (!level) return ctx.json({ error: 'Level is required' }, 400);
    
    try {
      await prisma.user.update({
        where: { id: userId },
        data: { level },
      });
      return ctx.json({ message: 'Level updated successfully' }, 200);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Database error' }, 500);
    }
  }
}
