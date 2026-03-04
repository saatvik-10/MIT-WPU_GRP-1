import { sign, verify } from 'hono/jwt';

interface JwtAuthProps {
  userId: string;
}

interface JwtVerifyResult {
  userId: string;
}

export const jwtAuth = async ({ userId }: JwtAuthProps) => {
  const payload = {
    userId,
    exp: Math.floor(Date.now() / 1000) + 30 * 24 * 60 * 60,
  };

  const token = await sign(payload, process.env.JWT_SECRET!, 'HS256');

  return token;
};

export const jwtVerify = async (token: string): Promise<JwtVerifyResult> => {
  try {
    const payload = await verify(token, process.env.JWT_SECRET!, 'HS256');
    return { userId: payload.userId as string };
  } catch {
    throw new Error('Invalid Token');
  }
};
