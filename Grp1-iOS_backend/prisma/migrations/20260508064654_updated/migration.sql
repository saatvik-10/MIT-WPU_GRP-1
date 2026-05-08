/*
  Warnings:

  - Made the column `threadId` on table `ThreadLike` required. This step will fail if there are existing NULL values in that column.

*/
-- DropIndex
DROP INDEX "ThreadLike_threadId_key";

-- AlterTable
ALTER TABLE "Thread" ALTER COLUMN "imageName" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ThreadLike" ALTER COLUMN "threadId" SET NOT NULL;

-- CreateTable
CREATE TABLE "ThreadCommentLike" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "commentId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ThreadCommentLike_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ThreadCommentLike_commentId_idx" ON "ThreadCommentLike"("commentId");

-- CreateIndex
CREATE INDEX "ThreadCommentLike_userId_idx" ON "ThreadCommentLike"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "ThreadCommentLike_userId_commentId_key" ON "ThreadCommentLike"("userId", "commentId");

-- CreateIndex
CREATE INDEX "ThreadLike_threadId_idx" ON "ThreadLike"("threadId");

-- CreateIndex
CREATE INDEX "ThreadLike_userId_idx" ON "ThreadLike"("userId");

-- AddForeignKey
ALTER TABLE "ThreadCommentLike" ADD CONSTRAINT "ThreadCommentLike_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ThreadCommentLike" ADD CONSTRAINT "ThreadCommentLike_commentId_fkey" FOREIGN KEY ("commentId") REFERENCES "ThreadComment"("id") ON DELETE CASCADE ON UPDATE CASCADE;
