import express from 'express';
import prisma from '../db/prisma.js';
import { authenticateToken, authenticateTokenAdm } from '../utils.js';

/**
 * @swagger
 * components:
 *   schemas:
 *     Parkour:
 *       type: object
 *       required:
 *         - name
 *         - description
 *         - status
 *       properties:
 *         name:
 *           type: string
 *           description: The unique name of the parkour
 *         description:
 *           type: string
 *           description: The unique description of the parkour
 *         uuid:
 *           type: string
 *           description: The unique identifier of the parkour
 *         createdAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the parkour was created
 *         updatedAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the parkour was last updated
 *         status:
 *           type: string
 *           description: The status of the parkour
 *         OrganisationId:
 *           type: integer
 *           description: The referenced organisation's id
 *         nodes:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/ParkourNode'
 *           description: The array of associated parkour nodes
 *       example:
 *         name: Parkour1
 *         description: An exciting parkour course
 *         uuid: abc123
 *         createdAt: '2023-01-01T12:00:00Z'
 *         updatedAt: '2023-01-02T15:30:00Z'
 *         status: Active
 *         OrganisationId: 1
 *         nodes:
 *           - parkourId: abc123
 *             nodeId: 1
 *             order: 1
 */

const parkour_router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Parkours
 *   description: The Parkours managing API
 * /api/parkours:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Get a list of all parkours
 *     tags: [Parkours]
 *     responses:
 *       200:
 *         description: Successfully retrieved parkours
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Parkour'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       500:
 *         description: Internal Server Error
 */
parkour_router.get('/', authenticateTokenAdm, async (req, res) => {
  const parkours = await prisma.parkour.findMany();
  res.send(parkours);
});

/**
 * @swagger
 * tags:
 *   name: Parkours
 *   description: The Parkours managing API
 * /api/parkours/orga/{id}:
 *   get:
 *     security:
 *       - bearerAuth: []
 *     summary: Get parkours associated with a specific organisation
 *     tags: [Parkours]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: The ID of the organisation
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Successfully retrieved parkours associated with the organisation
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Parkour'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       500:
 *         description: Internal Server Error
 *       404:
 *         description: Not Found - Organisation not found or no associated parkours
 */
parkour_router.get('/orga/:id', authenticateToken, async (req, res) => {
  const id = req.params.id;

  try {
    const parkours = await prisma.parkour.findMany({
      where: {
        OrganisationId: parseInt(id),
      },
    });
    return res.json(parkours);
  } catch (error) {
    console.error(error);
    return res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Parkours
 *   description: The Parkours managing API
 * /api/parkours/{id}:
 *   patch:
 *     security:
 *       - bearerAuth: []
 *     summary: Update a parkour and its associated nodes
 *     tags: [Parkours]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: The ID of the parkour to update
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            required:
 *             - name
 *             - description
 *             - status
 *             - organisation_id
 *             - node_ids
 *            properties:
 *              name:
 *                type: string
 *                description: The updated name of the parkour
 *              description:
 *                type: string
 *                description: The updated description of the parkour
 *              status:
 *                type: string
 *                description: The updated status of the parkour
 *              organisation_id:
 *                type: integer
 *                description: The updated ID of the associated organisation
 *              node_ids:
 *                type: array
 *                items:
 *                  type: integer
 *                description: An array of node IDs associated with the parkour
 *              order:
 *                type: array
 *                items:
 *                  type: integer
 *                description: An array of order values corresponding to the node IDs
 *              removed_node_ids:
 *                type: array
 *                items:
 *                  type: integer
 *                description: An array of node IDs to be removed from the parkour
 *     responses:
 *       200:
 *         description: Successfully updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Parkour'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       404:
 *         description: Not Found - Parkour not found
 *       500:
 *         description: Internal Server Error
 *       400:
 *         description: Bad Request - Missing required fields or invalid input
 */
parkour_router.patch('/:id', async (req, res) => {
  const id = req.params.id;

  try {
    const parkour = await prisma.parkour.findFirst({
      where: {
        uuid: id,
      },
    });
    if (parkour) {
      const updated_parkour = await prisma.parkour.update({
        where: {
          uuid: parkour.id,
        },
        data: {
          name: req.body.name || customer.name,
          description: req.body.description || customer.description,
          status: req.body.status || customer.status,
          OrganisationId: req.body.organisation_id || customer.OrganisationId,
          updatedAt: Date.now(),
          nodes: {
            upsert: req.body.node_ids.map((node_id, index) => ({
              where: {
                parkourId_nodeId: {
                  parkourId: updated_parkour.uuid,
                  nodeId: node_id,
                },
              },
              create: {
                parkourId: updated_parkour.uuid,
                nodeId: node_id,
                order: req.body.order[index] || 0,
              },
              update: {
                order: req.body.order[index] || 0,
              },
            })),
          },
        },
      });
      if (req.body.removed_node_ids && req.body.removed_node_ids.length > 0) {
        await prisma.parkour_node.deleteMany({
          where: {
            parkourId_nodeId: {
              parkourId: updated_parkour.uuid,
              nodeId: {
                in: req.body.removed_node_ids,
              },
            },
          },
        });
      }
      return res.json(updated_parkour);
    }
  } catch (error) {
    console.error(error);
    return res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Parkours
 *   description: The Parkours managing API
 * /api/parkours:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Create a new parkour with optional nodes
 *     tags: [Parkours]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            required:
 *             - name
 *             - description
 *             - status
 *            properties:
 *              name:
 *                type: string
 *                description: The name of the new parkour
 *              description:
 *                type: string
 *                description: The description of the new parkour
 *              status:
 *                type: string
 *                description: The status of the new parkour
 *              nodes:
 *                type: array
 *                items:
 *                  type: object
 *                  properties:
 *                    nodeId:
 *                      type: integer
 *                      description: The ID of the associated node
 *                    order:
 *                      type: integer
 *                      description: The order of the associated node (optional)
 *     responses:
 *       201:
 *         description: Successfully created a new parkour
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Parkour'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       500:
 *         description: Internal Server Error
 *       400:
 *         description: Bad Request - Missing required fields or invalid input
 */
parkour_router.post('/', async (req, res) => {
  try {
    const parkourData = {
      name: req.body.name,
      description: req.body.description,
      status: req.body.status,
      organisations: {
        connect: { id: req.body.organisationId },
      },
      OrganisationId: req.body.organisationId,
    };

    if (
      req.body.nodes &&
      Array.isArray(req.body.nodes) &&
      req.body.nodes.length > 0
    ) {
      parkourData.nodes = req.body.nodes.map((node) => ({
        nodeId: node.nodeId,
        order: node.order || 0,
      }));
    }

    const parkour = await prisma.parkour.create({
      data: parkourData,
    });

    res.json(parkour);
  } catch (error) {
    console.error(error);
    return res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Parkours
 *   description: The Parkours managing API
 * /api/parkours/{id}:
 *   delete:
 *     security:
 *       - bearerAuth: []
 *     summary: Delete a parkour and its associated nodes
 *     tags: [Parkours]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: The ID of the parkour to delete
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Successfully deleted the parkour and its associated nodes
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Parkour'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       404:
 *         description: Not Found - Parkour not found
 *       500:
 *         description: Internal Server Error
 */
parkour_router.delete('/:id', async (req, res) => {
  const id = req.params.id;
  try {
    await prisma.parkour_node.deleteMany({
      where: {
        parkourId: id,
      },
    });

    const deletedParkour = await prisma.parkour.delete({
      where: {
        uuid: id,
      },
    });

    res.json(deletedParkour);
  } catch (error) {
    console.error(error);
    return res.sendStatus(500);
  }
});

export default parkour_router;
