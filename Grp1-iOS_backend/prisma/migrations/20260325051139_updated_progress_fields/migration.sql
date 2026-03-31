/*
  Warnings:

  - You are about to drop the column `overallProgress` on the `UserProgress` table. All the data in the column will be lost.
  - You are about to drop the column `totalXP` on the `UserProgress` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "UserProgress" DROP COLUMN "overallProgress",
DROP COLUMN "totalXP";
