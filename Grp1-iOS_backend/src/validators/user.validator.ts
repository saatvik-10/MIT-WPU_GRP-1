import { z } from 'zod';

export const userSignUpSchema = z.object({
  name: z.string().min(3, 'Name must be atleast 3 characters long'),
  email: z.email('Email is required'),
  password: z.string().min(8, 'Password must be atleast 8 characters long'),
  profileImageUrl: z.string().optional(),
  phone: z.string(),
  level: z.enum(['BEGINNER', 'INTERMEDIATE', 'ADVANCE']),
  dob: z.string(),
  gender: z.enum(['MALE', 'FEMALE', 'OTHERS']),
  hasOnboarding: z.union([
    z.boolean(),
    z.string().transform((v) => v === 'true'),
  ]),
});

export const userSignInSchema = z.object({
  email: z.email('Email is required'),
  password: z.string().min(8, 'Password must be atleast 8 characters long'),
});

export const editProfileSchema = z.object({
  name: z.string().min(3, 'Name must be atleast 3 characters long').optional(),
  email: z.email('Invalid email').optional(),
  phone: z.string().optional(),
  dob: z.string().optional(),
  gender: z.enum(['MALE', 'FEMALE', 'OTHERS']).optional(),
});

export type UserSignUpType = z.infer<typeof userSignUpSchema>;
export type UserSignInType = z.infer<typeof userSignInSchema>;
export type EditProfileType = z.infer<typeof editProfileSchema>;
