/*
  Warnings:

  - You are about to drop the `_nodesToparkour` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "_nodesToparkour" DROP CONSTRAINT "_nodesToparkour_A_fkey";

-- DropForeignKey
ALTER TABLE "_nodesToparkour" DROP CONSTRAINT "_nodesToparkour_B_fkey";

-- DropTable
DROP TABLE "_nodesToparkour";

-- CreateTable
CREATE TABLE "parkour_node" (
    "parkourId" TEXT NOT NULL,
    "nodeId" INTEGER NOT NULL,

    CONSTRAINT "parkour_node_pkey" PRIMARY KEY ("parkourId","nodeId")
);

-- AddForeignKey
ALTER TABLE "parkour_node" ADD CONSTRAINT "parkour_node_parkourId_fkey" FOREIGN KEY ("parkourId") REFERENCES "parkour"("uuid") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "parkour_node" ADD CONSTRAINT "parkour_node_nodeId_fkey" FOREIGN KEY ("nodeId") REFERENCES "nodes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
