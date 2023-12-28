-- AlterTable
ALTER TABLE "nodes" ADD COLUMN     "altitude" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "model" TEXT,
ADD COLUMN     "texture" TEXT;
