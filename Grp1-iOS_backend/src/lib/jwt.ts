import type { Context } from 'hono';
import { sign } from 'hono/jwt';
import { setCookie } from 'hono/cookie';

interface JwtProps {
  userId: string;
  email: string;
  ctx: Context;
}

export const jwtAuth = async ({ userId, email, ctx }: JwtProps) => {
  const payload = {
    userId,
    email,
    exp: Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60,
  };

  const token = await sign(payload, process.env.JWT_SECRET!, 'EdDSA');

  setCookie(ctx, 'token', token, {
    httpOnly: true,
    sameSite: 'strict',
    secure: process.env.NODE_ENV === 'production',
  });

  return token;
};
