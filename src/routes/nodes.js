import express from 'express';

import prisma from '../db/prisma.js';

import { authenticateToken, authenticateTokenAdm } from '../utils.js';
//import {Node, User, Organisation} from '../db/models/index.js'

let node_router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Node:
 *       type: object
 *       required:
 *         - name
 *         - longitude
 *         - latitude
 *         - description
 *       properties:
 *         id:
 *           type: integer
 *           description: The auto-generated id of the node
 *         name:
 *           type: string
 *           description: The node's name
 *         description:
 *           type: string
 *           description: The node's description
 *         addressId:
 *           type: integer
 *           description: The referenced address's id
 *         OrganisationId:
 *           type: integer
 *           description: The referenced organisation's id
 *         longitude:
 *           type: number
 *           description: The longitude of the node
 *         latitude:
 *           type: number
 *           description: The latitude of the node
 *         status:
 *           type: string
 *           description: The status of the node
 *         filter:
 *           type: string
 *           description: WIP
 *         altitude:
 *           type: number
 *           description: The altitude of the node
 *         model:
 *           type: string
 *           description: The model of the node
 *         texture:
 *           type: string
 *           description: The texture of the node
 *       example:
 *         id: 12
 *         name: Louvre
 *         addressId: 5
 *         OrganisationId: 1
 *         description: A museum
 *         longitude: 152.0
 *         latitude: 35.0
 *         status: text
 *         filter: text
 *         altitude: 100.0
 *         model: example_model
 *         texture: example_texture
 */

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/admin:
 *   patch:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Modify the node's organisation id
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - name
 *             - OrganisationId
 *            type: object
 *            properties:
 *              name:
 *                type: string
 *              OrganisationId:
 *                type: number
 *     responses:
 *       200:
 *         description: The modified Node
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       500:
 *         descripton: Internal Server Error
 * /api/nodes:
 *   delete:
 *     security:
 *       - userBearerAuth: []
 *     summary: Delete a Node
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - name
 *            type: object
 *            properties:
 *              name:
 *                type: string
 *     responses:
 *       200:
 *         description: Confirmation string
 *         content:
 *           application/json:
 *             schema:
 *              type: object
 *              properties:
 *                body:
 *                  type: string
 *       404:
 *         description: Node not found
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Lists all the Nodes of the user's organisation
 *     tags: [Nodes]
 *     responses:
 *       200:
 *         description: The list of the Nodes of the user's organisation
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Node'
 *
 * /api/nodes/{names}:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Get Node by name
 *     tags: [Nodes]
 *     parameters:
 *       - in: path
 *         name: name
 *         schema:
 *           type: string
 *         required: true
 *         description: The Node's name
 *     responses:
 *       200:
 *        description: The Node response by name
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Node'
 *       404:
 *         description: Node not found
 * /api/nodes/all:
 *  get:
 *     summary: Lists all the Nodes
 *     tags: [Nodes]
 *     responses:
 *       200:
 *         description: The list of the Nodes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Node'
 */

node_router.get('/all', async (req, res) => {
  try {
    const nodes = await prisma.nodes.findMany({
      include: {
        guide: true,
      }
    });
    res.send(nodes);
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/filter:
 *   get:
 *     summary: Get nodes filtered by name
 *     parameters:
 *       - in: query
 *         name: filter
 *         required: true
 *         description: The filter string to match against node names
 *         schema:
 *           type: string
 *     tags: [Nodes]
 *     responses:
 *       200:
 *         description: Successfully retrieved filtered nodes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Node'
 *       500:
 *         description: Internal Server Error
 */
node_router.get('/filter', async (req, res) => {
  try {
    const filter = req.query.filter;
    const nodes = await prisma.nodes.findMany({
      where: {
        name: {
          contains: filter,
        },
      },
    });

    res.send(nodes);
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/admin:
 *   patch:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Modify node information (admin)
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             required:
 *               - name
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *               address:
 *                 type: integer
 *               description:
 *                 type: string
 *               model:
 *                 type: string
 *               texture:
 *                 type: string
 *               altitude:
 *                 type: number
 *               filter:
 *                 type: string
 *               parkour_uuid:
 *                 type: string
 *     responses:
 *       200:
 *         description: Successfully modified Node
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       404:
 *         description: Node not found
 *       500:
 *         description: Internal Server Error
 */
node_router.patch('/admin', authenticateTokenAdm, async (req, res) => {
  try {
    const node = await prisma.nodes.findUnique({
      where: {
        name: req.body.name,
      },
    });

    if (node) {
      let updatedNode = await prisma.nodes.update({
        where: {
          id: node.id,
        },
        data: {
          latitude: req.body.latitude || node.latitude,
          longitude: req.body.longitude || node.longitude,
          addressId: req.body.address || node.addressId,
          description: req.body.description || node.description,
          model: req.body.model || node.model,
          texture: req.body.texture || node.texture,
          altitude: req.body.altitude || node.altitude,
          filter: req.body.filter || node.filter,
        },
        include: {
          parkours: true,
        },
      });

      if (req.body.parkour_uuid) {
        const existingParkourNode = await prisma.parkour_node.findFirst({
          where: {
            parkourId: req.body.parkour_uuid,
            nodeId: updatedNode.id,
          },
        });

        if (!existingParkourNode) {
          await prisma.parkour_node.create({
            data: {
              parkourId: req.body.parkour_uuid,
              nodeId: updatedNode.id,
            },
          });
        }
      }

      res.json(updatedNode);
    } else {
      res.status(404).send('Node not found');
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/admin:
 *   delete:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Delete a node (admin)
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            required:
 *             - name
 *            properties:
 *              name:
 *                type: string
 *     responses:
 *       200:
 *         description: Node successfully deleted
 *       404:
 *         description: Node not found
 *       500:
 *         description: Internal Server Error
 */
node_router.delete('/admin', authenticateTokenAdm, async (req, res) => {
  try {
    const nodeName = req.body.name;

    await prisma.parkour_node.deleteMany({
      where: {
        nodeId: {
          name: nodeName,
        },
      },
    });
    const deletedNode = await prisma.nodes.delete({
      where: {
        name: nodeName,
      },
    });

    if (deletedNode) {
      res.send('success');
    } else {
      res.status(404).send('Node not found');
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/admin/parkour/{id}:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Get nodes associated with a parkour (admin)
 *     tags: [Nodes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID of the parkour
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of nodes associated with the parkour
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Node'
 *       404:
 *         description: Nodes not found for the specified parkour
 *       500:
 *         description: Internal Server Error
 */
node_router.get('/admin/parkour/:id', authenticateTokenAdm, async (req, res) => {
  try {
    const nodes = await prisma.parkour_node.findMany({
      where: {
        parkourId: req.params.id,
      },
      include: {
        node: true,
      },
      orderBy: {
        order: 'asc',
      },
    });

    if (nodes && nodes.length > 0) {
      return res.json(nodes);
    } else {
      return res.status(404).send('Nodes not found for the specified parkour');
    }
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
})

node_router.get('/', authenticateToken, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        email: req.email,
      },
    });
    if (user) {
      const orga = await prisma.organisations.findUnique({
        where: {
          id: user.OrganisationId,
        },
      });
      if (orga) {
        const nodes = await prisma.nodes.findMany({
          where: {
            OrganisationId: orga.id,
          },
          include: {
            guide: true,
          }
        });
        return res.send(nodes);
      } else
        return res
          .status(404)
          .send('This user is not part of any organisations.');
    }
    res.sendStatus(401);
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes/parkour/{id}:
 *   get:
 *     security:
 *       - bearerAuth: []
 *     summary: Get nodes associated with a specific parkour
 *     tags: [Nodes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: The ID of the parkour
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Nodes associated with the specified parkour
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Node'
 *       404:
 *         description: Nodes not found for the specified parkour
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       500:
 *         description: Internal Server Error
 */
node_router.get('/parkour/:id', authenticateToken, async (req, res) => {
  try {
    const nodes = await prisma.parkour_node.findMany({
      where: {
        parkourId: req.params.id,
      },
      include: {
        node: true,
      },
      orderBy: {
        order: 'asc',
      },
    });

    if (nodes && nodes.length > 0) {
      return res.json(nodes);
    } else {
      return res.status(404).send('Nodes not found for the specified parkour');
    }
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});

node_router.get('/:name', authenticateToken, async (req, res) => {
  try {
    const node = await prisma.nodes.findUnique({
      where: {
        name: req.params.name,
      },
      include: {
        guide: true,
      }
    });
    if (node) {
      return res.json(node);
    } else {
      return res.status(404).send('node not found');
    }
  } catch (err) {
    console.log(err);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes:
 *   post:
 *     security:
 *       - bearerAuth: []
 *     summary: Create a new node with optional parkours
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            required:
 *             - name
 *             - longitude
 *             - latitude
 *             - description
 *            properties:
 *              name:
 *                type: string
 *                description: The node's name
 *              longitude:
 *                type: number
 *                description: The longitude of the node
 *              latitude:
 *                type: number
 *                description: The latitude of the node
 *              description:
 *                type: string
 *                description: The node's description
 *              OrganisationId:
 *                type: integer
 *                description: The referenced organisation's id
 *              addressId:
 *                type: integer
 *                description: The referenced address's id
 *              status:
 *                type: string
 *                description: The status of the node
 *              filter:
 *                type: string
 *                description: WIP
 *              altitude:
 *                type: number
 *                description: The altitude of the node
 *              model:
 *                type: string
 *                description: The model of the node
 *              texture:
 *                type: string
 *                description: The texture of the node
 *              parkours:
 *                type: array
 *                items:
 *                  type: object
 *                  required:
 *                    - parkourId
 *                    - order
 *                  properties:
 *                    parkourId:
 *                      type: string
 *                      description: The ID of the associated parkour
 *                    order:
 *                      type: integer
 *                      description: The order of the parkour
 *     responses:
 *       201:
 *         description: Successfully created
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       500:
 *         description: Internal Server Error
 *       400:
 *         description: Bad Request - Missing required fields or invalid input
 */
node_router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log(req.body);
    if (
      req.body.name == null ||
      req.body.longitude == null ||
      req.body.latitude == null ||
      req.body.description == null
    ) {
      console.error('body is: ', req.body);
      throw new Error('Missing inputs');
    }

    const user = await prisma.user.findUnique({
      where: {
        email: req.email,
      },
    });

    if (user && user.OrganisationId) {
      const nodeData = {
        name: req.body.name,
        longitude: req.body.longitude,
        latitude: req.body.latitude,
        OrganisationId: user.OrganisationId,
        description: req.body.description,
        model: req.body.model,
        texture: req.body.texture,
        altitude: req.body.altitude,
        status: req.body.status,
      };

      if (
        req.body.parkours &&
        Array.isArray(req.body.parkours) &&
        req.body.parkours.length > 0
      ) {
        nodeData.parkours = {
          create: req.body.parkours.map((parkour) => ({
            parkourId: parkour.parkourId,
            order: parkour.order || 0,
          })),
        };
      }

      const node = await prisma.nodes.create({
        data: nodeData,
        include: {
          parkours: true,
        },
      });

      return res.json(node);
    }

    return res.sendStatus(401);
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes:
 *   patch:
 *     security:
 *       - bearerAuth: []
 *     summary: Update a node and its associated parkours
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            required:
 *             - name
 *            properties:
 *              name:
 *                type: string
 *                description: The name of the node to update
 *              latitude:
 *                type: number
 *                description: The updated latitude of the node
 *              longitude:
 *                type: number
 *                description: The updated longitude of the node
 *              address:
 *                type: integer
 *                description: The updated address ID of the node
 *              description:
 *                type: string
 *                description: The updated description of the node
 *              model:
 *                type: string
 *                description: The updated model of the node
 *              texture:
 *                type: string
 *                description: The updated texture of the node
 *              altitude:
 *                type: number
 *                description: The updated altitude of the node
 *              filter:
 *                type: string
 *                description: The updated filter of the node
 *              parkour_uuid:
 *                type: string
 *                description: The UUID of the associated parkour (optional)
 *     responses:
 *       200:
 *         description: Successfully updated
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       401:
 *         description: Unauthorized - Token is missing or invalid
 *       404:
 *         description: Not Found - Node not found
 *       500:
 *         description: Internal Server Error
 *       400:
 *         description: Bad Request - Missing required fields or invalid input
 */
node_router.patch('/', authenticateToken, async (req, res) => {
  try {
    const node = await prisma.nodes.findUnique({
      where: {
        name: req.body.name,
      },
    });

    if (node) {
      let updatedNode = await prisma.nodes.update({
        where: {
          id: node.id,
        },
        data: {
          latitude: req.body.latitude || node.latitude,
          longitude: req.body.longitude || node.longitude,
          addressId: req.body.address || node.addressId,
          description: req.body.description || node.description,
          model: req.body.model || node.model,
          texture: req.body.texture || node.texture,
          altitude: req.body.altitude || node.altitude,
          filter: req.body.filter || node.filter,
        },
        include: {
          parkours: true,
        },
      });

      if (req.body.parkour_uuid) {
        const existingParkourNode = await prisma.parkour_node.findFirst({
          where: {
            parkourId: req.body.parkour_uuid,
            nodeId: updatedNode.id,
          },
        });

        if (!existingParkourNode) {
          await prisma.parkour_node.create({
            data: {
              parkourId: req.body.parkour_uuid,
              nodeId: updatedNode.id,
            },
          });
        }
      }

      res.json(updatedNode);
    } else {
      res.status(404).send('Node not found');
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes:
 *   delete:
 *     summary: Delete a node and its association with a parkour
 *     security:
 *       - bearerAuth: []
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               node_id:
 *                 type: integer
 *                 description: The ID of the node to delete
 *               name:
 *                 type: string
 *                 description: The name of the node to delete
 *               parkour_id:
 *                 type: string
 *                 description: The ID of the parkour associated with the node
 *     responses:
 *       200:
 *         description: success
 *       404:
 *         description: Node not found
 *       500:
 *         description: Internal Server Error
 */
node_router.delete('/', authenticateToken, async (req, res) => {
  try {
    const nodeId = req.body.node_id;
    const nodeName = req.body.name;
    const parkourId = req.body.parkour_id;

    await prisma.parkour_node.delete({
      where: {
        parkourId_nodeId: {
          parkourId: parkourId,
          nodeId: nodeId,
        },
      },
    });

    const deletedNode = await prisma.nodes.delete({
      where: {
        name: nodeName,
      },
    });

    if (deletedNode) {
      res.send('success');
    } else {
      res.status(404).send('Node not found');
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

export default node_router;
