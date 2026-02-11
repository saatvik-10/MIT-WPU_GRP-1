import type { Context, Next } from 'hono';
import { getCookie } from 'hono/cookie';
import { jwtVerify } from './lib/jwt';

export const proxyAuth = async (ctx: Context, next: Next) => {
  const token = getCookie(ctx, 'token');

  if (!token) {
    ctx.text('Not Authenticated', 401);
    return;
  }

  const verified = await jwtVerify(token, ctx);

  ctx.set('userId', verified.userId);

  await next();
};
