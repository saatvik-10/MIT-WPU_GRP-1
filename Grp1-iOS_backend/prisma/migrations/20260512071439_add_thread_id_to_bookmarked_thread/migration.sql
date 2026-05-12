/*
  Warnings:

  - A unique constraint covering the columns `[userId,folderId,threadId]` on the table `BookmarkedThread` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `threadId` to the `BookmarkedThread` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "BookmarkedThread_userId_folderId_title_key";

-- AlterTable
ALTER TABLE "BookmarkedThread" ADD COLUMN     "threadId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "ThreadDrafts" ALTER COLUMN "threadId" DROP NOT NULL;

-- CreateIndex
CREATE INDEX "BookmarkedThread_threadId_idx" ON "BookmarkedThread"("threadId");

-- CreateIndex
CREATE UNIQUE INDEX "BookmarkedThread_userId_folderId_threadId_key" ON "BookmarkedThread"("userId", "folderId", "threadId");

-- AddForeignKey
ALTER TABLE "BookmarkedThread" ADD CONSTRAINT "BookmarkedThread_threadId_fkey" FOREIGN KEY ("threadId") REFERENCES "Thread"("id") ON DELETE CASCADE ON UPDATE CASCADE;
