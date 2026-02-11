import type { Context } from 'hono';
import { sign, verify } from 'hono/jwt';
import { setCookie } from 'hono/cookie';

interface JwtProps {
  userId: string;
  ctx: Context;
}

export const jwtAuth = async ({ userId, ctx }: JwtProps) => {
  const payload = {
    userId,
    exp: Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60,
  };

  const token = await sign(payload, process.env.JWT_SECRET!, 'HS256');

  setCookie(ctx, 'token', token, {
    httpOnly: true,
    sameSite: 'strict',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
  });

  return token;
};

export const jwtVerify = async (
  token: string,
  ctx: Context,
): Promise<JwtProps> => {
  try {
    const payload = await verify(token, process.env.JWT_SECRET!, 'HS256');
    return { userId: payload.userId as string, ctx };
  } catch {
    throw new Error('Invalid Token');
  }
};
