import type { Context, Next } from 'hono';
import { jwtVerify } from './lib/jwt';

export const proxyAuth = async (ctx: Context, next: Next) => {
  const authHeader = ctx.req.header('Authorization');
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.slice(7).trim()
    : undefined;

  if (!token) {
    return ctx.text('Not Authenticated', 401);
  }

  try {
    const verified = await jwtVerify(token);
    ctx.set('userId', verified.userId);
    await next();
  } catch {
    return ctx.text('Not Authenticated', 401);
  }
};

export const proxyOptionalAuth = async (ctx: Context, next: Next) => {
  const authHeader = ctx.req.header('Authorization');
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.slice(7).trim()
    : undefined;

  if (token) {
    try {
      const verified = await jwtVerify(token);
      ctx.set('userId', verified.userId);
    } catch {
      // ignore invalid tokens
    }
  }
  await next();
};
