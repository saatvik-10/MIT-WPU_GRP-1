/*
  Warnings:

  - A unique constraint covering the columns `[threadId]` on the table `ThreadLike` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `imageName` to the `Thread` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Thread" ADD COLUMN     "imageName" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "ThreadLike" ALTER COLUMN "threadId" DROP NOT NULL;

-- CreateTable
CREATE TABLE "ThreadDrafts" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "tags" TEXT[],
    "description" TEXT NOT NULL,
    "imageName" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "threadId" TEXT NOT NULL,

    CONSTRAINT "ThreadDrafts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ThreadDrafts_userId_idx" ON "ThreadDrafts"("userId");

-- CreateIndex
CREATE INDEX "ThreadDrafts_createdAt_idx" ON "ThreadDrafts"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "ThreadLike_threadId_key" ON "ThreadLike"("threadId");

-- AddForeignKey
ALTER TABLE "ThreadDrafts" ADD CONSTRAINT "ThreadDrafts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ThreadDrafts" ADD CONSTRAINT "ThreadDrafts_threadId_fkey" FOREIGN KEY ("threadId") REFERENCES "Thread"("id") ON DELETE CASCADE ON UPDATE CASCADE;
