import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { r2Service } from '../services/r2.service';
import formidable from 'formidable';
import { readFile } from 'fs/promises';
import { nanoid } from 'nanoid';
import {
  followSchema,
  createThreadSchema,
  threadDraftSchema,
  threadCommentSchema,
  threadLikeSchema,
} from '../validators/thread.validator';

export class Threads {
  async getForYouThreads(ctx: Context) {
    try {
      const threads = await prisma.thread.findMany({
        include: {
          user: true,
          likes: true,
          comments: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const threadsWithUrls = await Promise.all(
        threads.map(async (thread) => {
          let imageUrl = null;
          if (thread.imageName) {
            try {
              imageUrl = await r2Service.getPresignedUrl(thread.imageName);
            } catch (err) {
              console.error('Failed to get presigned URL:', err);
            }
          }
          return {
            ...thread,
            imageName: imageUrl,
          };
        }),
      );

      return ctx.json(threadsWithUrls);
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
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const threadsWithUrls = await Promise.all(
        threads.map(async (thread) => {
          let imageUrl = null;
          if (thread.imageName) {
            try {
              imageUrl = await r2Service.getPresignedUrl(thread.imageName);
            } catch (err) {
              console.error('Failed to get presigned URL:', err);
            }
          }
          return {
            ...thread,
            imageName: imageUrl,
          };
        }),
      );

      return ctx.json(threadsWithUrls);
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

  async getAllFollowers(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const followers = await prisma.follow.findMany({
        where: {
          followingId: userId,
        },
        include: {
          follower: true,
        },
      });

      return ctx.json(followers);
    } catch (err) {
      console.error('Error fetching followers:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getAllFollowing(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const following = await prisma.follow.findMany({
        where: {
          followerId: userId,
        },
        include: {
          following: true,
        },
      });

      return ctx.json(following);
    } catch (err) {
      console.error('Error fetching following:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async createThread(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const contentType = ctx.req.header('content-type');
      let formData: Record<string, any> = {};
      let threadImageS3Key: string | null = null;

      if (contentType?.includes('multipart/form-data')) {
        const nodeReq = ctx.env.incoming || (ctx.req as any).raw;
        const form = formidable({
          multiples: false,
          maxFileSize: 10 * 1024 * 1024,
        });

        const [fields, files] = await form.parse(nodeReq);

        Object.keys(fields).forEach((key) => {
          const field = fields[key];
          if (field) {
            formData[key] = Array.isArray(field) ? field[0] : field;
          }
        });

        if (files.threadImage) {
          const threadImageFile = Array.isArray(files.threadImage)
            ? files.threadImage[0]
            : files.threadImage;

          if (threadImageFile) {
            const fileBuffer = await readFile(threadImageFile.filepath);
            const fileName = threadImageFile.originalFilename || 'thread.jpg';
            const threadId = nanoid(12);

            threadImageS3Key = await r2Service.uploadThreadImage(
              threadId,
              fileName,
              fileBuffer,
            );
          }
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = createThreadSchema.safeParse(formData);

      if (!data.success) {
        return ctx.json(
          { error: 'Content is required and must be a string' },
          422,
        );
      }

      const thread = await prisma.thread.create({
        data: {
          userId,
          title: data.data.title,
          description: data.data.description,
          imageName: threadImageS3Key || '',
          tags: data.data.tags,
        },
      });

      return ctx.json(thread, 201);
    } catch (err) {
      console.error('Error creating thread:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async saveDraft(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const contentType = ctx.req.header('content-type');
      let formData: Record<string, any> = {};
      let draftImageS3Key: string | null = null;

      if (contentType?.includes('multipart/form-data')) {
        const nodeReq = ctx.env.incoming || (ctx.req as any).raw;
        const form = formidable({
          multiples: false,
          maxFileSize: 10 * 1024 * 1024,
        });

        const [fields, files] = await form.parse(nodeReq);

        Object.keys(fields).forEach((key) => {
          const field = fields[key];
          if (field) {
            formData[key] = Array.isArray(field) ? field[0] : field;
          }
        });

        if (files.threadImage) {
          const threadImageFile = Array.isArray(files.threadImage)
            ? files.threadImage[0]
            : files.threadImage;

          if (threadImageFile) {
            const fileBuffer = await readFile(threadImageFile.filepath);
            const fileName = threadImageFile.originalFilename || 'draft.jpg';
            const draftId = nanoid(12);

            draftImageS3Key = await r2Service.uploadThreadImage(
              draftId,
              fileName,
              fileBuffer,
            );
          }
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = threadDraftSchema.safeParse(formData);

      if (!data.success) {
        return ctx.json(
          { error: 'Content is required and must be a string' },
          422,
        );
      }

      const { threadId } = data.data;

      const draft = await prisma.threadDrafts.create({
        data: {
          userId,
          threadId,
          title: data.data.title,
          description: data.data.description,
          imageName: draftImageS3Key || '',
          tags: data.data.tags,
        },
      });

      return ctx.json(draft, 201);
    } catch (err) {
      console.error('Error saving draft:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getDrafts(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const drafts = await prisma.threadDrafts.findMany({
        where: {
          userId,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return ctx.json(drafts);
    } catch (err) {
      console.error('Error fetching drafts:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async createComment(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const data = threadCommentSchema.safeParse(await ctx.req.json());

      if (!data.success) {
        return ctx.json({ error: 'Invalid input' }, 422);
      }

      const { description, threadId } = data.data;

      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { id: true },
      });

      if (!thread) {
        return ctx.json({ error: 'Thread not found' }, 404);
      }

      const comment = await prisma.threadComment.create({
        data: {
          userId,
          threadId,
          description,
        },
      });

      await prisma.thread.update({
        where: { id: threadId },
        data: { commentsCount: { increment: 1 } },
      });

      return ctx.json(comment, 201);
    } catch (err) {
      console.error('Error creating comment:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async toggleLike(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const data = threadLikeSchema.safeParse(await ctx.req.json());

      if (!data.success) {
        return ctx.json({ error: 'Invalid input' }, 422);
      }

      const { threadId } = data.data;

      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { id: true },
      });

      if (!thread) {
        return ctx.json({ error: 'Thread not found' }, 404);
      }

      const existingLike = await prisma.threadLike.findUnique({
        where: {
          userId_threadId: {
            userId,
            threadId,
          },
        },
      });

      let liked = false;

      if (existingLike) {
        await prisma.threadLike.delete({
          where: { id: existingLike.id },
        });
        await prisma.thread.update({
          where: { id: threadId },
          data: { likesCount: { decrement: 1 } },
        });
      } else {
        await prisma.threadLike.create({
          data: {
            userId,
            threadId,
          },
        });
        await prisma.thread.update({
          where: { id: threadId },
          data: { likesCount: { increment: 1 } },
        });
        liked = true;
      }

      const updatedThread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { likesCount: true },
      });

      return ctx.json({
        liked,
        likesCount: updatedThread?.likesCount ?? 0,
      });
    } catch (err) {
      console.error('Error toggling like:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getComments(ctx: Context) {
    const threadId = ctx.req.query('threadId');

    if (!threadId) {
      return ctx.json({ error: 'threadId is required' }, 400);
    }

    try {
      const comments = await prisma.threadComment.findMany({
        where: { threadId },
        include: {
          user: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return ctx.json(comments);
    } catch (err) {
      console.error('Error fetching comments:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteDraft(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const draftId = ctx.req.query('draftId');

      if (!draftId) {
        return ctx.json({ error: 'draftId is required' }, 400);
      }

      const draft = await prisma.threadDrafts.findUnique({
        where: { id: draftId },
        select: { userId: true },
      });

      if (!draft) {
        return ctx.json({ error: 'Draft not found' }, 404);
      }

      if (draft.userId !== userId) {
        return ctx.json({ error: 'Unauthorized' }, 401);
      }

      await prisma.threadDrafts.delete({
        where: { id: draftId },
      });

      return ctx.json({ message: 'Draft deleted successfully' }, 200);
    } catch (err) {
      console.error('Error deleting draft:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteThread(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const threadId = ctx.req.query('threadId');

      if (!threadId) {
        return ctx.json({ error: 'threadId is required' }, 400);
      }

      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { userId: true },
      });

      if (!thread) {
        return ctx.json({ error: 'Thread not found' }, 404);
      }

      if (thread.userId !== userId) {
        return ctx.json({ error: 'Unauthorized' }, 401);
      }

      await prisma.thread.delete({
        where: { id: threadId },
      });

      return ctx.json({ message: 'Thread deleted successfully' }, 200);
    } catch (err) {
      console.error('Error deleting thread:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}

//TODO: thread in draft can be updated?
