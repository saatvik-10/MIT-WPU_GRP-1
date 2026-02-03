/*
  Warnings:

  - The values [Article,Threads] on the enum `BookmarkSource` will be removed. If these variants are still used in the database, this will fail.
  - The values [Male,Female,Others] on the enum `Gender` will be removed. If these variants are still used in the database, this will fail.
  - The values [Beginner,Intermediate,Advance] on the enum `Level` will be removed. If these variants are still used in the database, this will fail.
  - The values [User,Assistant] on the enum `Role` will be removed. If these variants are still used in the database, this will fail.
  - The values [Domain,Preference] on the enum `Type` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "BookmarkSource_new" AS ENUM ('ARTICLE', 'THREADS');
ALTER TABLE "Bookmark" ALTER COLUMN "sourceType" TYPE "BookmarkSource_new" USING ("sourceType"::text::"BookmarkSource_new");
ALTER TYPE "BookmarkSource" RENAME TO "BookmarkSource_old";
ALTER TYPE "BookmarkSource_new" RENAME TO "BookmarkSource";
DROP TYPE "public"."BookmarkSource_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Gender_new" AS ENUM ('MALE', 'FEMALE', 'OTHERS');
ALTER TABLE "User" ALTER COLUMN "gender" TYPE "Gender_new" USING ("gender"::text::"Gender_new");
ALTER TYPE "Gender" RENAME TO "Gender_old";
ALTER TYPE "Gender_new" RENAME TO "Gender";
DROP TYPE "public"."Gender_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Level_new" AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCE');
ALTER TABLE "public"."User" ALTER COLUMN "level" DROP DEFAULT;
ALTER TABLE "User" ALTER COLUMN "level" TYPE "Level_new" USING ("level"::text::"Level_new");
ALTER TYPE "Level" RENAME TO "Level_old";
ALTER TYPE "Level_new" RENAME TO "Level";
DROP TYPE "public"."Level_old";
ALTER TABLE "User" ALTER COLUMN "level" SET DEFAULT 'BEGINNER';
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Role_new" AS ENUM ('USER', 'ASSISTANT');
ALTER TABLE "ChatMessage" ALTER COLUMN "role" TYPE "Role_new" USING ("role"::text::"Role_new");
ALTER TYPE "Role" RENAME TO "Role_old";
ALTER TYPE "Role_new" RENAME TO "Role";
DROP TYPE "public"."Role_old";
COMMIT;

-- AlterEnum
BEGIN;
CREATE TYPE "Type_new" AS ENUM ('DOMAIN', 'PREFERENCE');
ALTER TABLE "Interest" ALTER COLUMN "type" TYPE "Type_new" USING ("type"::text::"Type_new");
ALTER TYPE "Type" RENAME TO "Type_old";
ALTER TYPE "Type_new" RENAME TO "Type";
DROP TYPE "public"."Type_old";
COMMIT;

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "level" SET DEFAULT 'BEGINNER';
