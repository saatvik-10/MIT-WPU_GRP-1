import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { r2Service } from '../services/r2.service';
import {
  createBookmarkFolderSchema,
  createBookmarkedArticleSchema,
  createBookmarkedThreadSchema,
} from '../validators/bookmark.validator';

export class Bookmarks {
  // Bookmark Folder Methods
  async createBookmarkFolder(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = createBookmarkFolderSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const { name } = data.data;

    try {
      const folder = await prisma.bookmarkFolder.create({
        data: {
          userId,
          name,
        },
      });

      return ctx.json(folder, 201);
    } catch (err) {
      console.error('Error creating bookmark folder:', err);
      if ((err as any).code === 'P2002') {
        return ctx.json({ error: 'Folder with this name already exists' }, 409);
      }
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getBookmarkFolders(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      const folders = await prisma.bookmarkFolder.findMany({
        where: {
          userId,
        },
        include: {
          _count: {
            select: {
              bookmarkedArticle: true,
              bookmarkedThread: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      return ctx.json(folders);
    } catch (err) {
      console.error('Error fetching bookmark folders:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteBookmarkFolder(ctx: Context) {
    const userId = ctx.get('userId');
    const folderId = ctx.req.param('folderId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!folderId) {
      return ctx.json({ error: 'folderId is required' }, 400);
    }

    try {
      const folder = await prisma.bookmarkFolder.findUnique({
        where: {
          id: folderId,
        },
      });

      if (!folder || folder.userId !== userId) {
        return ctx.json({ error: 'Folder not found' }, 404);
      }

      await prisma.bookmarkFolder.delete({
        where: {
          id: folderId,
        },
      });

      return ctx.json({ message: 'Folder deleted successfully' });
    } catch (err) {
      console.error('Error deleting bookmark folder:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  // Bookmarked Article Methods
  async createBookmarkedArticle(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = createBookmarkedArticleSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const {
      folderId,
      title,
      description,
      imageName,
      source,
      overview,
      keyTakeaways,
      jargons,
      date,
    } = data.data;

    try {
      // Verify folder exists and belongs to user
      const folder = await prisma.bookmarkFolder.findUnique({
        where: {
          id: folderId,
        },
      });

      if (!folder || folder.userId !== userId) {
        return ctx.json({ error: 'Folder not found' }, 404);
      }

      const bookmarkedArticle = await prisma.bookmarkedArticle.create({
        data: {
          userId,
          folderId,
          title,
          description,
          imageName,
          source,
          overview,
          keyTakeaways,
          jargons,
          date,
        },
      });

      return ctx.json(bookmarkedArticle, 201);
    } catch (err) {
      console.error('Error creating bookmarked article:', err);
      if ((err as any).code === 'P2002') {
        return ctx.json(
          { error: 'Article already bookmarked in this folder' },
          409,
        );
      }
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getBookmarkedArticles(ctx: Context) {
    const userId = ctx.get('userId');
    const folderId = ctx.req.query('folderId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      let where: any = { userId };

      if (folderId) {
        // Verify folder belongs to user
        const folder = await prisma.bookmarkFolder.findUnique({
          where: {
            id: folderId,
          },
        });

        if (!folder || folder.userId !== userId) {
          return ctx.json({ error: 'Folder not found' }, 404);
        }

        where.folderId = folderId;
      }

      const articles = await prisma.bookmarkedArticle.findMany({
        where,
        include: {
          folder: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const articlesWithUrls = await Promise.all(
        articles.map(async (article) => {
          let imageUrl = null;
          if (article.imageName) {
            try {
              imageUrl = await r2Service.getPresignedUrl(article.imageName);
            } catch (err) {
              console.error('Failed to get presigned URL:', err);
            }
          }
          return {
            ...article,
            imageName: imageUrl,
          };
        }),
      );

      return ctx.json(articlesWithUrls);
    } catch (err) {
      console.error('Error fetching bookmarked articles:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteBookmarkedArticle(ctx: Context) {
    const userId = ctx.get('userId');
    const articleId = ctx.req.param('articleId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!articleId) {
      return ctx.json({ error: 'articleId is required' }, 400);
    }

    try {
      const article = await prisma.bookmarkedArticle.findUnique({
        where: {
          id: articleId,
        },
      });

      if (!article || article.userId !== userId) {
        return ctx.json({ error: 'Article not found' }, 404);
      }

      await prisma.bookmarkedArticle.delete({
        where: {
          id: articleId,
        },
      });

      return ctx.json({ message: 'Article unbookmarked successfully' });
    } catch (err) {
      console.error('Error deleting bookmarked article:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  // Bookmarked Thread Methods
  async createBookmarkedThread(ctx: Context) {
    const userId = ctx.get('userId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    const data = createBookmarkedThreadSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json({ error: 'Invalid Input' }, 422);
    }

    const {
      folderId,
      threadId,
      title,
      description,
      imageName,
      tags,
    } = data.data;

    try {
      // Verify folder exists and belongs to user
      const folder = await prisma.bookmarkFolder.findUnique({
        where: {
          id: folderId,
        },
      });

      if (!folder || folder.userId !== userId) {
        return ctx.json({ error: 'Folder not found' }, 404);
      }

      // Verify thread exists
      const thread = await prisma.thread.findUnique({
        where: {
          id: threadId,
        },
      });

      if (!thread) {
        return ctx.json({ error: 'Thread not found' }, 404);
      }

      const bookmarkedThread = await prisma.bookmarkedThread.create({
        data: {
          userId,
          folderId,
          title,
          description,
          imageName,
          tags,
        },
      });

      return ctx.json(bookmarkedThread, 201);
    } catch (err) {
      console.error('Error creating bookmarked thread:', err);
      if ((err as any).code === 'P2002') {
        return ctx.json(
          { error: 'Thread already bookmarked in this folder' },
          409,
        );
      }
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async getBookmarkedThreads(ctx: Context) {
    const userId = ctx.get('userId');
    const folderId = ctx.req.query('folderId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    try {
      let where: any = { userId };

      if (folderId) {
        // Verify folder belongs to user
        const folder = await prisma.bookmarkFolder.findUnique({
          where: {
            id: folderId,
          },
        });

        if (!folder || folder.userId !== userId) {
          return ctx.json({ error: 'Folder not found' }, 404);
        }

        where.folderId = folderId;
      }

      const threads = await prisma.bookmarkedThread.findMany({
        where,
        include: {
          folder: true,
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
      console.error('Error fetching bookmarked threads:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }

  async deleteBookmarkedThread(ctx: Context) {
    const userId = ctx.get('userId');
    const threadId = ctx.req.param('threadId');

    if (!userId) {
      return ctx.json({ error: 'Unauthorized' }, 401);
    }

    if (!threadId) {
      return ctx.json({ error: 'threadId is required' }, 400);
    }

    try {
      const bookmarkedThread = await prisma.bookmarkedThread.findUnique({
        where: {
          id: threadId,
        },
      });

      if (!bookmarkedThread || bookmarkedThread.userId !== userId) {
        return ctx.json({ error: 'Bookmarked thread not found' }, 404);
      }

      await prisma.bookmarkedThread.delete({
        where: {
          id: threadId,
        },
      });

      return ctx.json({ message: 'Thread unbookmarked successfully' });
    } catch (err) {
      console.error('Error deleting bookmarked thread:', err);
      return ctx.json({ error: 'Internal server error' }, 500);
    }
  }
}
