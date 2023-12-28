/*
  Warnings:

  - Added the required column `order` to the `parkour_node` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "parkour_node" ADD COLUMN     "order" INTEGER NOT NULL;
