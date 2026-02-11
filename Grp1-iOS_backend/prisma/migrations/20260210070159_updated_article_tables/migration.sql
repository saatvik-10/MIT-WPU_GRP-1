/*
  Warnings:

  - You are about to drop the column `publishedDate` on the `Article` table. All the data in the column will be lost.
  - You are about to drop the column `subTitle` on the `Article` table. All the data in the column will be lost.
  - You are about to drop the column `jargons` on the `ArticleSummary` table. All the data in the column will be lost.
  - Added the required column `date` to the `Article` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "JargonPageType" AS ENUM ('DEFINITION', 'REAL_WORLD_EXAMPLE');

-- AlterTable
ALTER TABLE "Article" DROP COLUMN "publishedDate",
DROP COLUMN "subTitle",
ADD COLUMN     "date" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "ArticleSummary" DROP COLUMN "jargons";

-- CreateTable
CREATE TABLE "ArticleSummaryQuiz" (
    "id" TEXT NOT NULL,
    "summaryId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "options" TEXT[],
    "correctIndex" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ArticleSummaryQuiz_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ArticleSummaryQnA" (
    "id" TEXT NOT NULL,
    "summaryId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ArticleSummaryQnA_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Jargon" (
    "id" TEXT NOT NULL,
    "summaryId" TEXT NOT NULL,
    "jargonWord" TEXT NOT NULL,
    "title" "JargonPageType" NOT NULL,
    "content" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Jargon_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JargonQuiz" (
    "id" TEXT NOT NULL,
    "jargonId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "options" TEXT[],
    "correctIndex" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "JargonQuiz_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ArticleSummaryQuiz_summaryId_idx" ON "ArticleSummaryQuiz"("summaryId");

-- CreateIndex
CREATE INDEX "ArticleSummaryQnA_summaryId_idx" ON "ArticleSummaryQnA"("summaryId");

-- CreateIndex
CREATE INDEX "Jargon_summaryId_idx" ON "Jargon"("summaryId");

-- CreateIndex
CREATE UNIQUE INDEX "JargonQuiz_jargonId_key" ON "JargonQuiz"("jargonId");

-- AddForeignKey
ALTER TABLE "ArticleSummaryQuiz" ADD CONSTRAINT "ArticleSummaryQuiz_summaryId_fkey" FOREIGN KEY ("summaryId") REFERENCES "ArticleSummary"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ArticleSummaryQnA" ADD CONSTRAINT "ArticleSummaryQnA_summaryId_fkey" FOREIGN KEY ("summaryId") REFERENCES "ArticleSummary"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Jargon" ADD CONSTRAINT "Jargon_summaryId_fkey" FOREIGN KEY ("summaryId") REFERENCES "ArticleSummary"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JargonQuiz" ADD CONSTRAINT "JargonQuiz_jargonId_fkey" FOREIGN KEY ("jargonId") REFERENCES "Jargon"("id") ON DELETE CASCADE ON UPDATE CASCADE;
