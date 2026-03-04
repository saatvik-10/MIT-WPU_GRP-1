/*
  Warnings:

  - You are about to drop the column `summaryId` on the `ArticleSummaryQnA` table. All the data in the column will be lost.
  - You are about to drop the column `totalQuizzesPlayes` on the `UserProfile` table. All the data in the column will be lost.
  - You are about to drop the `Article` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ArticleSummary` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ArticleSummaryQuiz` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Jargon` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `JargonQuiz` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `articleTitle` to the `ArticleSummaryQnA` table without a default value. This is not possible if the table is not empty.
  - Added the required column `articleUrl` to the `ArticleSummaryQnA` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "QuizType" AS ENUM ('JARGON', 'SUMMARY');

-- DropForeignKey
ALTER TABLE "Article" DROP CONSTRAINT "Article_categoryId_fkey";

-- DropForeignKey
ALTER TABLE "ArticleSummary" DROP CONSTRAINT "ArticleSummary_articleId_fkey";

-- DropForeignKey
ALTER TABLE "ArticleSummaryQnA" DROP CONSTRAINT "ArticleSummaryQnA_summaryId_fkey";

-- DropForeignKey
ALTER TABLE "ArticleSummaryQuiz" DROP CONSTRAINT "ArticleSummaryQuiz_summaryId_fkey";

-- DropForeignKey
ALTER TABLE "Jargon" DROP CONSTRAINT "Jargon_summaryId_fkey";

-- DropForeignKey
ALTER TABLE "JargonQuiz" DROP CONSTRAINT "JargonQuiz_jargonId_fkey";

-- DropIndex
DROP INDEX "ArticleSummaryQnA_summaryId_idx";

-- AlterTable
ALTER TABLE "ArticleSummaryQnA" DROP COLUMN "summaryId",
ADD COLUMN     "articleTitle" TEXT NOT NULL,
ADD COLUMN     "articleUrl" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "UserProfile" DROP COLUMN "totalQuizzesPlayes",
ADD COLUMN     "totalQuizzesPlayed" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "totalXP" INTEGER NOT NULL DEFAULT 0;

-- DropTable
DROP TABLE "Article";

-- DropTable
DROP TABLE "ArticleSummary";

-- DropTable
DROP TABLE "ArticleSummaryQuiz";

-- DropTable
DROP TABLE "Jargon";

-- DropTable
DROP TABLE "JargonQuiz";

-- DropEnum
DROP TYPE "JargonPageType";

-- CreateTable
CREATE TABLE "QuizAttempt" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "articleUrl" TEXT NOT NULL,
    "quizTitle" TEXT NOT NULL,
    "quizType" "QuizType" NOT NULL,
    "score" INTEGER NOT NULL,
    "totalQuestions" INTEGER NOT NULL,
    "accuracyPercentage" DOUBLE PRECISION NOT NULL,
    "xpEarned" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuizAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "QuizAttempt_userId_idx" ON "QuizAttempt"("userId");

-- CreateIndex
CREATE INDEX "QuizAttempt_articleUrl_idx" ON "QuizAttempt"("articleUrl");

-- CreateIndex
CREATE INDEX "QuizAttempt_createdAt_idx" ON "QuizAttempt"("createdAt");

-- CreateIndex
CREATE INDEX "ArticleSummaryQnA_articleUrl_idx" ON "ArticleSummaryQnA"("articleUrl");

-- AddForeignKey
ALTER TABLE "QuizAttempt" ADD CONSTRAINT "QuizAttempt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
