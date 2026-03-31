import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { r2Service } from '../services/r2.service';
import { nanoid } from 'nanoid';
import {
  followSchema,
  createThreadSchema,
  threadDraftSchema,
  updateThreadDraftSchema,
  threadCommentSchema,
  threadLikeSchema,
  commentLikeSchema,
} from '../validators/thread.validator';


async function parseMultipart(ctx: Context, imageFieldName: string) {
  const body = await ctx.req.parseBody();
  const fields: Record<string, any> = {};
  for (const [key, value] of Object.entries(body)) {
    // Handle tags[] array fields from Swift
    if (key === 'tags[]') {
      if (Array.isArray(value)) {
        fields['tags'] = value.filter(v => typeof v === 'string');
      } else if (typeof value === 'string') {
        if (!fields['tags']) fields['tags'] = [];
        fields['tags'].push(value);
      }
    } 
    // Handle tags already parsed as array by Hono
    else if (key === 'tags') {
      if (Array.isArray(value)) {
        fields['tags'] = value.filter(v => typeof v === 'string');
      } else if (typeof value === 'string') {
        fields['tags'] = [value];
      }
    }
    else if (typeof value === 'string') {
      fields[key] = value;
    }
  }
  const imageFile = body[imageFieldName];
  const file = imageFile instanceof File ? imageFile : null;
  return { fields, file };
}

export class Threads {
  async getForYouThreads(ctx: Context) {
    const userId = ctx.get('userId');
    try {
      const threads = await prisma.thread.findMany({
        include: { user: true, likes: true, comments: true },
        orderBy: { createdAt: 'desc' },
      });

      const threadsWithUrls = await Promise.all(
        threads.map(async (thread) => {
          let imageUrl: string | null = null;
          if (thread.imageName && thread.imageName.trim() !== '') {
            try {
              imageUrl = await r2Service.getPresignedUrl(thread.imageName);
            } catch (err) {
              console.error(
                `[Threads] Failed presign for ${thread.imageName}:`,
                err,
              );
            }
          }
          const isLiked = userId
            ? thread.likes.some((like) => like.userId === userId)
            : false;

          return { ...thread, imageUrl, isLiked };
        }),
      );

      return ctx.json(threadsWithUrls);
    } catch (err) {
      console.error('Error fetching threads:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getFollowingThreads(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const followingUsers = await prisma.follow.findMany({
        where: { followerId: userId },
        select: { followingId: true },
      });

      const followingIds = followingUsers.map((f) => f.followingId);

      const threads = await prisma.thread.findMany({
        where: { userId: { in: followingIds } },
        include: { user: true, likes: true, comments: true },
        orderBy: { createdAt: 'desc' },
      });

      const threadsWithUrls = await Promise.all(
        threads.map(async (thread) => {
          let imageUrl: string | null = null;
          if (thread.imageName && thread.imageName.trim() !== '') {
            try {
              imageUrl = await r2Service.getPresignedUrl(thread.imageName);
            } catch (err) {
              console.error(
                `[Threads] Failed presign for ${thread.imageName}:`,
                err,
              );
            }
          }
          const isLiked = thread.likes.some((like) => like.userId === userId);

          return { ...thread, imageUrl, isLiked };
        }),
      );

      return ctx.json(threadsWithUrls);
    } catch (err) {
      console.error('Error fetching following threads:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async createThread(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const contentType = ctx.req.header('content-type') ?? '';
      let formData: Record<string, any> = {};
      let threadImageS3Key: string | null = null;

      if (contentType.includes('multipart/form-data')) {
        const { fields, file } = await parseMultipart(ctx, 'threadImage');
        formData = fields;

        if (file) {
          console.log(
            `[Threads] Processing image: ${file.name}, size: ${file.size} bytes`,
          );
          const arrayBuffer = await file.arrayBuffer();
          const fileBuffer = Buffer.from(arrayBuffer);
          const threadId = nanoid(12);
          threadImageS3Key = await r2Service.uploadThreadImage(
            threadId,
            file.name || 'thread.jpg',
            fileBuffer,
          );
          console.log(`[Threads] Image stored with key: ${threadImageS3Key}`);
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = createThreadSchema.safeParse(formData);
      if (!data.success) {
        console.error('[Threads] Validation failed:', data.error.flatten());
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
          imageName: threadImageS3Key ?? null!,
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
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const contentType = ctx.req.header('content-type') ?? '';
      let formData: Record<string, any> = {};
      let draftImageS3Key: string | null = null;

      if (contentType.includes('multipart/form-data')) {
        const { fields, file } = await parseMultipart(ctx, 'threadImage');
        formData = fields;

        if (file) {
          const arrayBuffer = await file.arrayBuffer();
          const fileBuffer = Buffer.from(arrayBuffer);
          const draftId = nanoid(12);
          draftImageS3Key = await r2Service.uploadThreadImage(
            draftId,
            file.name || 'draft.jpg',
            fileBuffer,
          );
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = threadDraftSchema.safeParse(formData);
      if (!data.success)
        return ctx.json(
          { error: 'Content is required and must be a string' },
          422,
        );

      const draft = await prisma.threadDrafts.create({
        data: {
          userId,
          threadId: data.data.threadId,
          title: data.data.title,
          description: data.data.description,
          imageName: draftImageS3Key ?? null!,
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
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const drafts = await prisma.threadDrafts.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      });
      return ctx.json(drafts);
    } catch (err) {
      console.error('Error fetching drafts:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async updateDraft(ctx: Context) {
    const userId = ctx.get('userId');
    const draftId = ctx.req.param('draftId');

    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    if (!draftId) return ctx.json({ error: 'draftId is required' }, 400);

    try {
      const draft = await prisma.threadDrafts.findUnique({
        where: { id: draftId },
        select: { userId: true },
      });

      if (!draft) return ctx.json({ error: 'Draft not found' }, 404);
      if (draft.userId !== userId)
        return ctx.json({ error: 'Unauthorized' }, 401);

      const contentType = ctx.req.header('content-type') ?? '';
      let formData: Record<string, any> = {};
      let draftImageS3Key: string | null = null;

      if (contentType.includes('multipart/form-data')) {
        const { fields, file } = await parseMultipart(ctx, 'threadImage');
        formData = fields;

        if (file) {
          const arrayBuffer = await file.arrayBuffer();
          const fileBuffer = Buffer.from(arrayBuffer);
          draftImageS3Key = await r2Service.uploadThreadImage(
            draftId,
            file.name || 'draft.jpg',
            fileBuffer,
          );
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = updateThreadDraftSchema.safeParse(formData);
      if (!data.success) return ctx.json({ error: 'Invalid input' }, 422);

      const updateData: any = {};
      if (data.data.title !== undefined) updateData.title = data.data.title;
      if (data.data.description !== undefined)
        updateData.description = data.data.description;
      if (data.data.tags !== undefined) updateData.tags = data.data.tags;
      if (draftImageS3Key) updateData.imageName = draftImageS3Key;

      const updatedDraft = await prisma.threadDrafts.update({
        where: { id: draftId },
        data: updateData,
      });

      return ctx.json(updatedDraft);
    } catch (err) {
      console.error('Error updating draft:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async updateFollow(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    const data = followSchema.safeParse(await ctx.req.json());
    if (!data.success) return ctx.json({ error: 'Invalid Input' }, 422);

    const { followingId } = data.data;
    if (userId === followingId)
      return ctx.json({ error: 'You cannot follow yourself' }, 400);

    try {
      const targetUser = await prisma.user.findUnique({
        where: { id: followingId },
        select: { id: true },
      });
      if (!targetUser) return ctx.json({ error: 'User not found' }, 404);

      const existingFollow = await prisma.follow.findUnique({
        where: { followerId_followingId: { followerId: userId, followingId } },
      });

      let action: 'followed' | 'unfollowed' = 'followed';

      if (existingFollow) {
        await prisma.follow.delete({
          where: {
            followerId_followingId: { followerId: userId, followingId },
          },
        });
        action = 'unfollowed';
      } else {
        await prisma.follow.create({
          data: { followerId: userId, followingId },
        });
      }

      const [followersCount, followingCount] = await Promise.all([
        prisma.follow.count({ where: { followingId } }),
        prisma.follow.count({ where: { followerId: userId } }),
      ]);

      return ctx.json({ action, followersCount, followingCount }, 200);
    } catch (err) {
      console.error('Error updating follow:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getAllFollowers(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    try {
      const followers = await prisma.follow.findMany({
        where: { followingId: userId },
        include: { follower: true },
      });
      return ctx.json(followers);
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getAllFollowing(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    try {
      const following = await prisma.follow.findMany({
        where: { followerId: userId },
        include: { following: true },
      });
      return ctx.json(following);
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async createComment(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const data = threadCommentSchema.safeParse(await ctx.req.json());
      if (!data.success) return ctx.json({ error: 'Invalid input' }, 422);

      const { description, threadId } = data.data;
      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { id: true },
      });
      if (!thread) return ctx.json({ error: 'Thread not found' }, 404);

      const comment = await prisma.threadComment.create({
        data: { userId, threadId, description },
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
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const data = threadLikeSchema.safeParse(await ctx.req.json());
      if (!data.success) return ctx.json({ error: 'Invalid input' }, 422);

      const { threadId } = data.data;
      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { id: true },
      });
      if (!thread) return ctx.json({ error: 'Thread not found' }, 404);

      const existingLike = await prisma.threadLike.findUnique({
        where: { userId_threadId: { userId, threadId } },
      });
      let liked = false;

      if (existingLike) {
        try {
          await prisma.threadLike.delete({
            where: { userId_threadId: { userId, threadId } },
          });
          await prisma.thread.update({
            where: { id: threadId },
            data: { likesCount: { decrement: 1 } },
          });
        } catch (e: any) {
          // If already deleted concurrently
          if (e.code !== 'P2025') throw e; 
        }
      } else {
        try {
          await prisma.threadLike.create({ data: { userId, threadId } });
          await prisma.thread.update({
            where: { id: threadId },
            data: { likesCount: { increment: 1 } },
          });
          liked = true;
        } catch (e: any) {
          // If already created concurrently
          if (e.code === 'P2002') {
             liked = true;
          } else {
             throw e;
          }
        }
      }

      const updatedThread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { likesCount: true },
      });
      return ctx.json({ liked, likesCount: updatedThread?.likesCount ?? 0 });
    } catch (err) {
      console.error('Error toggling like:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

    async getComments(ctx: Context) {
    const threadId = ctx.req.query('threadId');
    const userId = ctx.get('userId'); // Read user (optional)
    if (!threadId) return ctx.json({ error: 'threadId is required' }, 400);
    try {
      const comments = await prisma.threadComment.findMany({
        where: { threadId },
        include: { user: true, likes: true }, // Include likes strictly for the true/false calculation
        orderBy: { createdAt: 'desc' },
      });
      // Format response to include isLiked
      const formattedComments = comments.map(c => {
        const isLiked = userId ? c.likes.some(l => l.userId === userId) : false;
        const { likes, ...rest } = c; // drop the raw array
        return { ...rest, isLiked };
      });
      return ctx.json(formattedComments);
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }  

  async toggleCommentLike(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);
    try {
      const data = commentLikeSchema.safeParse(await ctx.req.json());
      if (!data.success) return ctx.json({ error: 'Invalid input' }, 422);
      const { commentId } = data.data;
      const comment = await prisma.threadComment.findUnique({
        where: { id: commentId }, select: { id: true }
      });
      if (!comment) return ctx.json({ error: 'Comment not found' }, 404);
      const existingLike = await prisma.threadCommentLike.findUnique({
        where: { userId_commentId: { userId, commentId } }
      });
      let liked = false;
      // Simply create or delete the relation
      if (existingLike) {
        await prisma.threadCommentLike.delete({
          where: { userId_commentId: { userId, commentId } }
        });
      } else {
        await prisma.threadCommentLike.create({
          data: { userId, commentId }
        });
        liked = true;
      }
      // NO COUNTER RETURNED
      return ctx.json({ liked });
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteDraft(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const draftId = ctx.req.query('draftId');
      if (!draftId) return ctx.json({ error: 'draftId is required' }, 400);

      const draft = await prisma.threadDrafts.findUnique({
        where: { id: draftId },
        select: { userId: true },
      });
      if (!draft) return ctx.json({ error: 'Draft not found' }, 404);
      if (draft.userId !== userId)
        return ctx.json({ error: 'Unauthorized' }, 401);

      await prisma.threadDrafts.delete({ where: { id: draftId } });
      return ctx.json({ message: 'Draft deleted successfully' }, 200);
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteThread(ctx: Context) {
    const userId = ctx.get('userId');
    if (!userId) return ctx.json({ error: 'Unauthorized' }, 401);

    try {
      const threadId = ctx.req.query('threadId');
      if (!threadId) return ctx.json({ error: 'threadId is required' }, 400);

      const thread = await prisma.thread.findUnique({
        where: { id: threadId },
        select: { userId: true },
      });
      if (!thread) return ctx.json({ error: 'Thread not found' }, 404);
      if (thread.userId !== userId)
        return ctx.json({ error: 'Unauthorized' }, 401);

      await prisma.thread.delete({ where: { id: threadId } });
      return ctx.json({ message: 'Thread deleted successfully' }, 200);
    } catch (err) {
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}
