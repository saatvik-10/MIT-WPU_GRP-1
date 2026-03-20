/*
  Warnings:

  - You are about to drop the column `sharesCount` on the `Thread` table. All the data in the column will be lost.
  - You are about to drop the `Bookmark` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ThreadShare` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `description` to the `ThreadComment` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Bookmark" DROP CONSTRAINT "Bookmark_folderId_fkey";

-- DropForeignKey
ALTER TABLE "Bookmark" DROP CONSTRAINT "Bookmark_userId_fkey";

-- DropForeignKey
ALTER TABLE "ThreadShare" DROP CONSTRAINT "ThreadShare_threadId_fkey";

-- DropForeignKey
ALTER TABLE "ThreadShare" DROP CONSTRAINT "ThreadShare_userId_fkey";

-- DropIndex
DROP INDEX "BookmarkFolder_name_key";

-- AlterTable
ALTER TABLE "Thread" DROP COLUMN "sharesCount";

-- AlterTable
ALTER TABLE "ThreadComment" ADD COLUMN     "description" TEXT NOT NULL;

-- DropTable
DROP TABLE "Bookmark";

-- DropTable
DROP TABLE "ThreadShare";

-- DropEnum
DROP TYPE "BookmarkSource";

-- CreateTable
CREATE TABLE "BookmarkedArticle" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "folderId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "imageName" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "overview" TEXT[],
    "keyTakeaways" TEXT[],
    "jargons" TEXT[],
    "date" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BookmarkedArticle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookmarkedThread" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "folderId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "imageName" TEXT NOT NULL,
    "tags" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BookmarkedThread_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "BookmarkedArticle_userId_idx" ON "BookmarkedArticle"("userId");

-- CreateIndex
CREATE INDEX "BookmarkedArticle_folderId_idx" ON "BookmarkedArticle"("folderId");

-- CreateIndex
CREATE UNIQUE INDEX "BookmarkedArticle_userId_folderId_title_key" ON "BookmarkedArticle"("userId", "folderId", "title");

-- CreateIndex
CREATE INDEX "BookmarkedThread_userId_idx" ON "BookmarkedThread"("userId");

-- CreateIndex
CREATE INDEX "BookmarkedThread_folderId_idx" ON "BookmarkedThread"("folderId");

-- CreateIndex
CREATE UNIQUE INDEX "BookmarkedThread_userId_folderId_title_key" ON "BookmarkedThread"("userId", "folderId", "title");

-- AddForeignKey
ALTER TABLE "BookmarkedArticle" ADD CONSTRAINT "BookmarkedArticle_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookmarkedArticle" ADD CONSTRAINT "BookmarkedArticle_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES "BookmarkFolder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookmarkedThread" ADD CONSTRAINT "BookmarkedThread_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookmarkedThread" ADD CONSTRAINT "BookmarkedThread_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES "BookmarkFolder"("id") ON DELETE CASCADE ON UPDATE CASCADE;
