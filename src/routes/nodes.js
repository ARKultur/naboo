import express from "express";

import prisma from '../db/prisma.js'

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
//import {Node, User, Organisation} from '../db/models/index.js'

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
 *         status:
 *           type: string
 *           description: The status of the node
 *         filter:
 *           type: string
 *           description: WIP
 *       example:
 *         id: 12
 *         name: Louvre
 *         addressId: 5
 *         OrganisationId: 1
 *         description: A museum
 *         longitude: 152
 *         latitude: 35
 *         status: text
 *         filter: text
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
 *             - description
 *            type: object
 *            properties:
 *              name:
 *                type: string
 *              longitude:
 *                type: number
 *              latitude:
 *                type: number
 *              description:
 *                type: string
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
 *              description:
 *                type: string
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
	//const nodes = await Node.findAll();

	const nodes = await prisma.nodes.findMany();
	res.send(nodes)
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

node_router.patch('/admin', authenticateTokenAdm, async (req, res) => {
    try {
	/*
	const node = await Node.findOne({
            where: {
		name: req.body.name
            }
	});
	*/

	const node = await prisma.nodes.findUnique({
	    where: {
		name: req.body.name
	    }
	})
	if (node)
	{
	    /*
            await node.update({
		OrganisationId: req.body.OrganisationId || node.OrganisationId
		});
	    */
	    const new_node = await prisma.nodes.update({
		where: {
		    name: node.name
		},
		data: {
		    OrganisationId: req.body.OrganisationId || node.OrganisationId,
		    name: req.body.name,                                                                                                                                                                                                    
                    longitude: req.body.longitude || node.longitude,
                    latitude: req.body.latitude || node.latitude,
                    addressId: req.body.addressId || node.addressId,
                    description: req.body.description || node.description,
		    status: req.body.status || node.status
		}
	    })
            res.json(new_node)
	}
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
})

node_router.delete('/admin', authenticateTokenAdm, async (req, res) => {
    try {
	const node = await prisma.nodes.delete({
	    where: {
		name: req.body.name
	    }
	})
	if (node)
	{
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

node_router.get('/', authenticateToken, async (req, res) => {
    try {
	/*
    const user = await User.findOne({
        where: {
            email: req.email
        }
	})
	*/
	const user = await prisma.user.findUnique({
	    where: {
		email: req.email
	    }
	})
    if (user)
    {
        //const orga = await Organisation.findByPk(user.OrganisationId)
	const orga = await prisma.organisations.findUnique({
	    where: {
		id: user.OrganisationId
	    }
	})
	if (orga)
        {
	    /*
            const nodes = await Node.findAll({
                where: {
                    OrganisationId: orga.id
                }
		});
	    */
	    const nodes = await prisma.nodes.findMany({
		where: {
		    OrganisationId: orga.id
		}
	    })
            return res.send(nodes)
        } else
	    return res.status(404).send("This user is not part of any organisations.")
    }
	res.sendStatus(401)
    } catch (err)
    {
	console.log(err)
	res.sendStatus(500)
    }
})


node_router.get('/parkour/:id', authenticateToken, async (req, res) => {
	try {
		const nodes = await prisma.parkour_node.findMany({
			where: {
				parkourId: req.params.id
			},
			include: {
				node: true
			}
		})
		if (nodes)
		{
			return res.json(nodes)
		} else {
			return res.status(404).send("node not found")
		}
		} catch (err)
		{
		console.log(err)
		res.sendStatus(500)
		}
})

node_router.get('/:name', authenticateToken, async (req, res) => {
    try {
	const node = await prisma.nodes.findUnique({
	    where: {
		name: req.params.name
	    }
	})
    if (node)
    {
        return res.json(node)
    } else {
        return res.status(404).send("node not found")
    }
    } catch (err)
    {
	console.log(err)
	res.sendStatus(500)
    }
})

node_router.post('/', authenticateToken, async (req, res) => {
    
    try {
	if (req.body.name == null || req.body.longitude == null || req.body.latitude == null || !req.body.description == null)
	    {
		throw new Error("Missing inputs")
	    }
	/*
	const user = await User.findOne({
        where: {
            email: req.email
        }
	})
	*/
	const user = await prisma.user.findUnique({
	    where: {
		email: req.email
	    }
	})
	if (user) {
	    if (user.OrganisationId)
	    {
		/*
		  const node = await Node.create({
		  name: req.body.name,
		  longitude: req.body.longitude,
		  latitude: req.body.latitude,
		  OrganisationId: user.OrganisationId,
		  description: req.body.description
		  });
		*/
		const node = await prisma.nodes.create({
		    data: {
			name: req.body.name,
			longitude: req.body.longitude,
			latitude: req.body.latitude,
			OrganisationId: user.OrganisationId,
			description: req.body.description,
			parkours: []
		    }
		})
            	return res.json(node)
	    }
	}
	return res.sendStatus(401)
    } catch (error) {
	console.log(error)
        res.sendStatus(500);
    }
})

node_router.patch('/', authenticateToken, async (req, res) => {

    try {
	/*
	  const node = await Node.findOne({
          where: {
          name: req.body.name
          }
	  });
	*/
	const node = await prisma.nodes.findUnique({
	    where: {
		name: req.body.name
	    }
	})
	if (node)
	{
	    /*
            await node.update({
		latitude: req.body.latitude || node.latitude,
		longitude: req.body.longitude || node.longitude,
		addressId: req.body.address || node.addressId,
		description: req.body.description || node.description
            });
	    */
	    const new_node = await prisma.nodes.update({
		where: {
		    id: node.id
		},
		data: {
		    latitude: req.body.latitude || node.latitude,
		    longitude: req.body.longitude || node.longitude,
		    addressId: req.body.address || node.addressId,
		    description: req.body.description || node.description
		}
	    })

		if (req.body.parkour_uuid)
		{
			await prisma.parkour_node.create({
				data: {
					parkourId: req.body.parkour_uuid,
					nodeId: new_node.id
				}
			})
		}
	    res.json(new_node)
	}
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

node_router.delete('/', authenticateToken, async (req, res) => {
    try {
	/*
	const node = await Node.findOne({
            where:{
		name: req.body.name
            }
	})
	*/
	const node = await prisma.nodes.delete({
	    where: {
		name: req.body.name
	    }
	})
	if (node)
	{
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
