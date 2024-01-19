import express from "express";
import multer from "multer";

import prisma from '../db/prisma.js'

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
import fs from "fs";
//import {Guide, User, Organisation, Node} from "../db/models/index.js"

let guide_router = express.Router()

/**
 * @swagger
 * components:
 *   schemas:
 *     Guide:
 *       type: object
 *       required:
 *         - text
 *       properties:
 *         id:
 *           type: integer
 *           description: The auto-generated id of the guide
 *         text:
 *           type: string
 *           description: The guide's text
 *         NodeId:
 *           type: integer
 *           description: The referenced node's id
 *       example:
 *         id: 12
 *         text: this is a very cool monument
 *         NodeId: 5
 */

/**
 * @swagger
 * tags:
 *   name: Guides
 *   description: The Guides managing API
 * /api/guides:
 *   post:
 *     security:
 *       - userBearerAuth: []
 *     summary: Create a guide
 *     tags: [Guides]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - text
 *            type: object
 *            properties:
 *              text:
 *                type: string
 *     responses:
 *       200:
 *         description: The created guide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Guide'
 *       500:
 *         description: Unexpected error
 *   patch:
 *     security:
 *       - userBearerAuth: []
 *     summary: Edit a guide
 *     tags: [Guides]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - id
 *            type: object
 *            properties:
 *              text:
 *                type: string
 *              id:
 *                type: integer
 *              node:
 *                type: integer
 *                description: The referenced node id
 *     responses:
 *       200:
 *         description: The edited guide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Guide'
 *       404:
 *         description: Guide not found
 *
 *   delete:
 *     security:
 *       - userBearerAuth: []
 *     summary: Delete a guide
 *     tags: [Guides]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - id
 *            type: object
 *            properties:
 *              id:
 *                type: integer
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
 *         description: Guide not found
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Lists all the Guides of the user's organisation
 *     tags: [Guides]
 *     responses:
 *       200:
 *         description: The list of the Guides of the user's organisation
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Guide'
 *
 * /api/guides/{id}:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Get guide by id
 *     tags: [Guides]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: The guide's id
 *     responses:
 *       200:
 *        description: The Guide response by id
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Guide'
 *       404:
 *         description: Guide not found
 *
 * /api/guides/admin:
 *  get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Lists all the Guides
 *     tags: [Guides]
 *     responses:
 *       200:
 *         description: The list of the Guides
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Guide'
 */

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

guide_router.post('/:guideId/images', upload.single('file'), authenticateToken, async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: {
                email: req.email
            }
        })

        if (!req.params.guideId) {
            return res.status(400).send('You need to provide a correct guide id.');
        }

        const guide = await prisma.guide.findUnique({
            where: {
                id: parseInt(req.params.guideId)
            }
        })

        if (!guide || !user || !user.OrganisationId) {
            return res.status(401).send("You can't upload file without user account link to an organization");
        }

        console.log(`file : ${JSON.stringify(req.file.filename, null, 2)}`);

        const file = await prisma.file.create({
          data: {
            guideId: guide.id,
            filename: req.file.originalname,
            content: req.file.buffer,
          },
        });

        console.log(`File saved in database: ${JSON.stringify(file.filename, null, 2)}`);
        res.send('File uploaded and saved in database');
      } catch (error) {
        console.error('Error uploading file:', error);
        res.status(500).send('Internal Server Error');
      }
});

guide_router.get('/:guideId/images/:id', async (req, res) => {
    try {
        const fileId = parseInt(req.params.id);

        const file = await prisma.file.findUnique({
            where: {
                id: fileId,
            },
        });

        if (!file) {
            return res.status(404).send('File not found');
        }

        res.set({
            'Content-Type': 'application/octet-stream',
            'Content-Disposition': `attachment; filename=${file.filename}`,
        });

        res.send(Buffer.from(file.content, 'utf8'));
    } catch (error) {
        console.error('Error retrieving file:', error);
        res.status(500).send('Internal Server Error');
    }
});

guide_router.get('/:guideId/images', async (req, res) => {
    const guideId = parseInt(req.params.guideId);

    const files = await prisma.file.findMany({
        where: {
            guideId: guideId,
        },
        select: {
            id: true,
            filename: true,
        }
    });

    res.send(files);
});

guide_router.get("/admin", authenticateTokenAdm, async (req,res) => {
    //const guides = await Guide.findAll()
    const guides = await prisma.guide.findMany();
    res.send(guides)
})

guide_router.get("/", authenticateToken, async (req,res) => {
    const user = await prisma.user.findUnique({
        where: {
            email: req.email
        }
    })
    if (user)
    {
        const orga = await prisma.organisations.findUnique({
            where: {
                id: user.OrganisationId
            }
        })
        if (orga)
        {
            const nodes = await prisma.nodes.findMany({
                where: {
                    OrganisationId: orga.id
                }
	        })
            let all_guides = [];
            for (const iterator of nodes) {
                const guides = await prisma.guide.findMany({
                    where: {
                        NodeId: iterator.id
                    }
                })
                all_guides.push(guides);
            }
            return res.json(all_guides);
        }
    }
    res.status(401).send();
})

guide_router.get("/:id", async (req, res) => {
    const guide = await prisma.guide.findUnique({
        where: {
            id: parseInt(req.params.id)
        },
        include: {
            reviews: true && {
                include: {
                    user: {
                        select: {
                            username: true
                        }
                    }
                }
            }
        }
    })
    if (!guide || guide == null)
    {
        return res.status(404).json({error: "Guide not found"})
    }
    return res.json(guide);
})

guide_router.post("/", authenticateToken, async (req, res) => {
    try {
        const guide = await prisma.guide.create({
            data: {
                title: req.body.title,
                description: req.body.description,
                keywords: req.body.keywords,
                openingHours: req.body.openingHours,
                priceDesc: req.body.priceDesc,
                priceValue: req.body.priceValue,
                website: req.body.website,
            },
        })
        res.json(guide);
    } catch (err)
    {
        console.log(err);
        res.status(500).send("unexpected error");
      }
})

guide_router.patch("/", authenticateToken, async (req,res) => {
    try {
        /*
        const guide = await Guide.findOne({
                where: {
            id: req.body.id
                }
        });

        await guide.update({
                text: req.body.text || guide.text,
                NodeId: req.body.node || guide.NodeId
        })
        */

        const guide = await prisma.guide.findUnique({
            where: {
                id: req.body.id
            }
        })

        if (!guide)
            return res.status(404).send("Guide not found")
        const new_guide = await prisma.guide.update({
            where: {
                id: guide.id
            },
            data: {
                title: req.body.title || guide.title,
                description: req.body.description || guide.description,
                keywords: req.body.keywords || guide.keywords,
                openingHours: req.body.openingHours || guide.openingHours,
                website: req.body.website || guide.website,
                priceDesc: req.body.priceDesc || guide.priceDesc,
                priceValue: req.body.priceValue || guide.priceValue,
                NodeId: req.body.node || guide.NodeId
            }
        })
        res.json(new_guide)
    } catch (err) {
	    res.sendStatus(500);
    }
})

guide_router.patch("/:id", authenticateToken, async (req,res) => {
    const guide = await prisma.guide.findUnique({
        where: {
            id: parseInt(req.params.id)
        }
    })

    if (!guide)
        return res.status(404).send("Guide not found")

    const new_guide = await prisma.guide.update({
        where: {
            id: guide.id
        },
        data: {
            NodeId: req.body.node || guide.NodeId,
            title: req.body.title || guide.title,
            description: req.body.description || guide.description,
            keywords: req.body.keywords || guide.keywords,
            openingHours: req.body.openingHours || guide.openingHours,
            priceDesc: req.body.priceDesc || guide.priceDesc,
            priceValue: req.body.priceValue || guide.priceValue,
            website: req.body.website || guide.website,
        }
    })
    res.json(new_guide)
})

guide_router.delete("/:id", authenticateToken, async (req, res) => {
    const deleted = await prisma.guide.delete({
        where: {
            id: parseInt(req.params.id)
        }
    })

    if (!deleted)
        return res.status(404).send("Guide not found")

    res.send("success");
})

export default guide_router;
