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
});

export const userSignInSchema = z.object({
  email: z.email('Email is required'),
  password: z.string().min(8, 'Password must be atleast 8 characters long'),
});

export type UserSignUpType = z.infer<typeof userSignUpSchema>;
export type UserSignInType = z.infer<typeof userSignInSchema>;
