/*
  Warnings:

  - You are about to drop the column `articleTitle` on the `ArticleSummaryQnA` table. All the data in the column will be lost.
  - You are about to drop the column `articleUrl` on the `ArticleSummaryQnA` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "ArticleSummaryQnA_articleUrl_idx";

-- AlterTable
ALTER TABLE "ArticleSummaryQnA" DROP COLUMN "articleTitle",
DROP COLUMN "articleUrl";
