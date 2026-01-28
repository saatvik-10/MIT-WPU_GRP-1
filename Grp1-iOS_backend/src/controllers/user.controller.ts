import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { jwtAuth } from '../lib/jwt';
import { hashPassword } from '../lib/hashPassword';
import { userSignInSchema, userSignUpSchema } from '../validators/user.validator';

export class UserAuth {
  async signup(ctx: Context) {
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
}
