import express from "express";

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
import {Node, User, Organisation} from '../db/models/index.js'

let node_router = express.Router()

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
 *       example:
 *         id: 12
 *         name: Louvre
 *         addressId: 5
 *         OrganisationId: 1
 *         description: A museum
 *         longitude: 152
 *         latitude: 35
 */

/**
 * @swagger
 * tags:
 *   name: Nodes
 *   description: The Nodes managing API
 * /api/nodes:
 *   post:
 *     security:
 *       - userBearerAuth: []
 *     summary: Create a Node
 *     tags: [Nodes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - name
 *             - longitude
 *             - latitude 
 *            type: object
 *            properties:
 *              name:
 *                type: string
 *              longitude:
 *                type: number
 *              latitude:
 *                type: number
 *     responses:
 *       200:
 *         description: The created Node
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       500:
 *         description: Node already existing
 *   patch:
 *     security:
 *       - userBearerAuth: []
 *     summary: Edit a Node
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
 *              longitude:
 *                type: number
 *              latitude:
 *                type: number
 *              address:
 *                type: integer
 *              organisation:
 *                type: integer
 *     responses:
 *       200:
 *         description: The edited Node
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Node'
 *       404:
 *         description: Node not found
 * 
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
    const nodes = await Node.findAll();
	res.send(nodes)
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

node_router.get('/', authenticateToken, async (req, res) => {
    try {
    const user = await User.findOne({
        where: {
            email: req.email
        }
    })
    if (user)
    {
        const orga = await Organisation.findByPk(user.OrganisationId)
        if (orga)
        {
            const nodes = await Node.findAll({
                where: {
                    OrganisationId: orga.id
                }
            });
            return res.send(nodes)
        } else
	    return res.status(404).send("This user is not part of any organisations.")
    }
	res.sendStatus(401)
    } catch (err)
    {
	res.sendStatus(500)
    }
})

node_router.get('/:name', authenticateToken, async (req, res) => {
    try {
    const node = await Node.findOne({
        where: {
            name: req.params.name
        }
    });
    if (node)
    {
        return res.send(node.toJSON())
    } else {
        return res.status(404).send("node not found")
    }
    } catch (err)
    {
	res.sendStatus(500)
    }
})

node_router.post('/', authenticateToken, async (req, res) => {
    
    try {
	if (!req.body.name || !req.body.longitude || !req.body.latitude)
	    {
		throw new Error("")
	    }
	const user = await User.findOne({
        where: {
            email: req.email
        }
	})
	if (user) {
		if (user.OrganisationId)
		{
		const node = await Node.create({
		    name: req.body.name,
		    longitude: req.body.longitude,
		    latitude: req.body.latitude,
		    OrganisationId: user.OrganisationId
		});
            	return res.send(node.toJSON())
		}
	}
	return res.sendStatus(401)
    } catch (error) {
        res.sendStatus(500);
    }
})

node_router.patch('/', authenticateToken, async (req, res) => {

    try {
    const node = await Node.findOne({
        where: {
            name: req.body.name
        }
    });

    if (node)
    {
        await node.update({
            latitude: req.body.latitude || node.latitude,
            longitude: req.body.longitude || node.longitude,
            addressId: req.body.address || node.addressId,
            OrganisationId:req.body.organisation || node.OrganisationId 
        });
        res.send(node.toJSON())
    }
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

node_router.delete('/', authenticateToken, async (req, res) => {
    try {
    const node = await Node.findOne({
        where:{
          name: req.body.name
        }
      })
    
      if (node)
      {
        await node.destroy()
        res.send("success")
      } else {
        res.status(404).send("Node not found");
      }
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500);
    }
})

export default node_router;
