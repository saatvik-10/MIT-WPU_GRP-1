import type { Context } from 'hono';
import { prisma } from '../../prisma';
import {
  createBookmarkFolderSchema,
  createBookmarkSchema,
} from '../validators/bookmark.validator';
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
              return ctx.json({ error: 'Error fetching follower image' }, 500);
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

      // Fetch presigned URLs for profile images
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
              // Keep original URL if presigned URL fails
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

  async createBookmarkFolder(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = createBookmarkFolderSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const folderName = data.data.name;

    try {
      const existingFolder = await prisma.bookmarkFolder.findUnique({
        where: {
          userId_name: {
            userId,
            name: folderName,
          },
        },
      });

      if (existingFolder) {
        return ctx.json({ error: 'Folder already exists' }, 409);
      }

      const folder = await prisma.bookmarkFolder.create({
        data: {
          userId,
          name: folderName,
        },
      });

      return ctx.json(folder, 201);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error creating bookmark folder' }, 500);
    }
  }

  async createBookmark(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = createBookmarkSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const { folderId, title, url, sourceType, imageUrl, description } =
      data.data;

    try {
      const folder = await prisma.bookmarkFolder.findFirst({
        where: {
          id: folderId,
          userId,
        },
      });

      if (!folder) {
        return ctx.json({ error: 'Folder not found' }, 404);
      }

      const bookmark = await prisma.bookmark.create({
        data: {
          userId,
          folderId,
          title,
          url,
          imageUrl: imageUrl ?? '',
          description: description ?? '',
          sourceType,
        },
      });

      return ctx.json(bookmark, 201);
    } catch (err) {
      console.log(err);
      return ctx.json({ error: 'Error creating bookmark' }, 500);
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

  async getBookmarkFolders(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const bookmarkFolders = await prisma.bookmarkFolder.findMany({
        where: {
          userId,
        },
        include: {
          _count: {
            select: {
              bookmarks: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });
      return ctx.json(bookmarkFolders, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Err fetching bookmark folders', 500);
    }
  }

  async getBookmarks(ctx: Context) {
    const userId = ctx.get('userId');
    const folderId = ctx.req.query('folderId');

    if (!userId) {
      return ctx.json('Unauthorized', 401);
    }

    if (!folderId) {
      return ctx.json('Folder ID is required', 400);
    }

    try {
      const bookmarks = await prisma.bookmark.findMany({
        where: {
          userId,
          folderId,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return ctx.json(bookmarks, 200);
    } catch (err) {
      console.log(err);
      return ctx.json('Error fetching bookmarks', 500);
    }
  }
}
