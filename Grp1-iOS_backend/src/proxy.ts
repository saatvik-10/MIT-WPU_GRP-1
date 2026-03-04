import type { Context, Next } from 'hono';
import { jwtVerify } from './lib/jwt';

export const proxyAuth = async (ctx: Context, next: Next) => {
  const authHeader = ctx.req.header('Authorization');
  const token = authHeader?.startsWith('Bearer ')
    ? authHeader.slice(7).trim()
    : undefined;

  if (!token) {
    ctx.text('Not Authenticated', 401);
    return;
  }

  try {
    const verified = await jwtVerify(token);
    ctx.set('userId', verified.userId);
    await next();
  } catch {
    ctx.text('Not Authenticated', 401);
  }
};
