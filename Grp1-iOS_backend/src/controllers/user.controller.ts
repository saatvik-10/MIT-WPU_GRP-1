import type { Context } from 'hono';
import { prisma } from '../../prisma';
import { jwtAuth } from '../lib/jwt';
import { comparePassword, hashPassword } from '../lib/hashPassword';
import {
  userSignInSchema,
  userSignUpSchema,
} from '../validators/user.validator';
import { nanoid } from 'nanoid';
import { r2Service } from '../services/r2.service';
import formidable from 'formidable';
import { readFile } from 'fs/promises';

export class UserAuth {
  async signUp(ctx: Context) {
    try {
      const contentType = ctx.req.header('content-type');
      let formData: Record<string, any> = {};
      let profileImageS3Key: string | null = null;

      if (contentType?.includes('multipart/form-data')) {
        const nodeReq = ctx.env.incoming || (ctx.req as any).raw;
        const form = formidable({
          multiples: false,
          maxFileSize: 5 * 1024 * 1024,
        });

        const [fields, files] = await form.parse(nodeReq);

        Object.keys(fields).forEach((key) => {
          const field = fields[key];
          if (field) {
            formData[key] = Array.isArray(field) ? field[0] : field;
          }
        });

        if (files.profileImage) {
          const profileImageFile = Array.isArray(files.profileImage)
            ? files.profileImage[0]
            : files.profileImage;

          if (profileImageFile) {
            const fileBuffer = await readFile(profileImageFile.filepath);
            const fileName = profileImageFile.originalFilename || 'profile.jpg';

            const temp_username =
              formData.name.split(' ')[0]?.toLowerCase() +
              '_' +
              nanoid(4).toLowerCase();
            const temp_id = nanoid(12);

            profileImageS3Key = await r2Service.uploadProfileImage(
              temp_id,
              fileName,
              fileBuffer,
            );
          }
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = userSignUpSchema.safeParse(formData);

      const username =
        data.data?.name.split(' ')[0]?.toLowerCase() +
        '_' +
        nanoid(4).toLowerCase();

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
            username: username,
            email: data.data.email,
            password: hashedPassword,
            phone: data.data.phone,
            level: data.data.level,
            dob: data.data.dob,
            gender: data.data.gender,
            hasOnboarding: data.data.hasOnboarding,
            profileImageUrl: profileImageS3Key || undefined,
          },
        });

        return ctx.json(newUser.id, 201);
      } catch (err) {
        if (profileImageS3Key) {
          try {
            await r2Service.deleteProfileImage(profileImageS3Key);
          } catch (deleteErr) {
            console.error('Failed to clean up R2 file:', deleteErr);
          }
        }
        console.log(err);
        return ctx.json('Server Err', 500);
      }
    } catch (err) {
      console.log('Signup error:', err);
      return ctx.json('Server Err', 500);
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

    const token = await jwtAuth({ userId: user.id });

    return ctx.json({ userId: user.id, token }, 200);
  }

  async getMe(ctx: Context) {
    try {
      const userId = ctx.get('userId');

      if (!userId) {
        return ctx.json('Unauthorized', 401);
      }

      return ctx.json({ userId }, 200);
    } catch (err) {
      return ctx.json('Unauthorized', 401);
    }
  }

  async signout(ctx: Context) {
    try {
      return ctx.json('User signed out. Please remove token on client.', 200);
    } catch (err) {
      return ctx.json('Server Error', 500);
    }
  }
}
