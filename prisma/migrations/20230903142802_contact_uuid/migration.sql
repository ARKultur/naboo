/*
  Warnings:

  - The primary key for the `contact` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The `uuid` column on the `contact` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- AlterTable
ALTER TABLE "contact" DROP CONSTRAINT "contact_pkey",
DROP COLUMN "uuid",
ADD COLUMN     "uuid" SERIAL NOT NULL,
ADD CONSTRAINT "contact_pkey" PRIMARY KEY ("uuid");
