import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { getCookie, deleteCookie } from 'hono/cookie';
import { jwtAuth, jwtVerify } from '../lib/jwt';
import { comparePassword, hashPassword } from '../lib/hashPassword';
import {
  userSignInSchema,
  userSignUpSchema,
} from '../validators/user.validator';

export class UserAuth {
  async signUp(ctx: Context) {
    const data = userSignUpSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json('Invalid Input', 422);
    }

    try {
      const existingUser = await prisma.user.findUnique({
        where: {
          email: data.data.email,
        },
      });

      if (existingUser) {
        return ctx.json('User with this email already exists', 409);
      }

      const hashedPassword = await hashPassword(data.data.password);

      const newUser = await prisma.user.create({
        data: {
          name: data.data.name,
          email: data.data.email,
          password: hashedPassword,
          phone: data.data.phone,
          level: data.data.level,
          dob: data.data.dob,
          gender: data.data.gender,
        },
      });

      return ctx.json(newUser.id, 201);
    } catch (err) {
      console.log(err);
      ctx.json('Server Err', 500);
    }
  }

  async signIn(ctx: Context) {
    const data = userSignInSchema.safeParse(await ctx.req.json());

    if (!data.success) {
      return ctx.json('Invalid Input', 422);
    }

    let user = await prisma.user.findUnique({
      where: {
        email: data.data.email,
      },
    });

    if (!user) {
      return ctx.json('User with this email does not exist', 404);
    }

    const validUser = await comparePassword(data.data.password, user.password);

    if (!validUser) {
      return ctx.json('Email or password is wrong', 400);
    }

    await jwtAuth({ userId: user.id, ctx });

    return ctx.json({ userId: user.id }, 200);
  }

  async getMe(ctx: Context) {
    try {
      const token = getCookie(ctx, 'token');

      if (!token) {
        return ctx.json('Unauthorized', 401);
      }

      const userId = await jwtVerify(token, ctx);

      const user = await prisma.user.findUnique({
        where: {
          id: userId.userId,
        },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          level: true,
          dob: true,
          gender: true,
          profileImageUrl: true,
        },
      });

      if (!user) {
        return ctx.json('User not found', 404);
      }

      return ctx.json(user, 200);
    } catch (err) {
      return ctx.json('Unauthorized', 401);
    }
  }

  async signout(ctx: Context) {
    try {
      deleteCookie(ctx, 'token');
      return ctx.json('User signed Out', 200);
    } catch (err) {
      return ctx.json('Server Error', 500);
    }
  }
}
