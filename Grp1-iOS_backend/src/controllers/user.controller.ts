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

export class UserAuth {
  async signUp(ctx: Context) {
    try {
      const contentType = ctx.req.header('content-type') ?? '';
      let formData: Record<string, any> = {};
      let profileImageS3Key: string | null = null;

      if (contentType.includes('multipart/form-data')) {
        // ✅ Hono's built-in parseBody — works in ALL runtimes, no formidable needed

        const body = await ctx.req.parseBody();

// 🔍 TEMPORARY DEBUG — remove after fix
console.log('[DEBUG] Body keys:', Object.keys(body));
console.log('[DEBUG] profileImage type:', typeof body['profileImage']);
console.log('[DEBUG] profileImage is File:', body['profileImage'] instanceof File);
console.log('[DEBUG] profileImage value:', body['profileImage']);

        // Extract text fields
        for (const [key, value] of Object.entries(body)) {
          if (typeof value === 'string') {
            formData[key] = value;
          }
        }

        // Extract image file
        const imageFile = body['profileImage'];

        if (imageFile && imageFile instanceof File) {
          console.log(
            `[UserAuth] Processing profile image: ${imageFile.name}, size: ${imageFile.size} bytes`,
          );
          const arrayBuffer = await imageFile.arrayBuffer();
          const fileBuffer = Buffer.from(arrayBuffer);
          const fileName = imageFile.name || 'profile.jpg';
          const tempId = nanoid(12);

          profileImageS3Key = await r2Service.uploadProfileImage(
            tempId,
            fileName,
            fileBuffer,
          );
          console.log(
            `[UserAuth] Profile image stored with key: ${profileImageS3Key}`,
          );
        }
      } else {
        formData = await ctx.req.json();
      }

      const data = userSignUpSchema.safeParse(formData);

      if (!data.success) {
        console.error('[UserAuth] Validation failed:', data.error.flatten());
        if (profileImageS3Key)
          await r2Service
            .deleteProfileImage(profileImageS3Key)
            .catch(console.error);
        return ctx.json('Invalid Input', 422);
      }

      const username =
        data.data.name.split(' ')[0]?.toLowerCase() +
        '_' +
        nanoid(4).toLowerCase();

      try {
        const existingUser = await prisma.user.findUnique({
          where: { email: data.data.email },
        });

        if (existingUser) {
          if (profileImageS3Key)
            await r2Service
              .deleteProfileImage(profileImageS3Key)
              .catch(console.error);
          return ctx.json('User with this email already exists', 409);
        }

        const hashedPassword = await hashPassword(data.data.password);

        const newUser = await prisma.user.create({
          data: {
            name: data.data.name,
            username,
            email: data.data.email,
            password: hashedPassword,
            phone: data.data.phone,
            level: data.data.level,
            dob: data.data.dob,
            gender: data.data.gender,
            hasOnboarding: true as boolean,
            profileImageUrl: profileImageS3Key ?? null,
          },
        });

        return ctx.json(newUser.id, 201);
      } catch (err) {
        if (profileImageS3Key)
          await r2Service
            .deleteProfileImage(profileImageS3Key)
            .catch(console.error);
        console.error('[UserAuth] DB error during signup:', err);
        return ctx.json('Server Err', 500);
      }
    } catch (err) {
      console.error('[UserAuth] Signup error:', err);
      return ctx.json('Server Err', 500);
    }
  }

  async signIn(ctx: Context) {
    const data = userSignInSchema.safeParse(await ctx.req.json());

    if (!data.success) return ctx.json('Invalid Input', 422);

    const user = await prisma.user.findUnique({
      where: { email: data.data.email },
    });

    if (!user) return ctx.json('User with this email does not exist', 404);

    const validUser = await comparePassword(data.data.password, user.password);

    if (!validUser) return ctx.json('Email or password is wrong', 400);

    const token = await jwtAuth({ userId: user.id });

    return ctx.json({ userId: user.id, token }, 200);
  }

  async getMe(ctx: Context) {
    try {
      const userId = ctx.get('userId');
      if (!userId) return ctx.json('Unauthorized', 401);
      return ctx.json({ userId }, 200);
    } catch (err) {
      return ctx.json('Unauthorized', 401);
    }
  }
}
