import express from "express";

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
import {Guide, User, Organisation, Node} from "../db/models/index.js"

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
 * 
 * /api/guides/{id}:
 *   get:
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
 */


guide_router.get("/", authenticateTokenAdm, async (req,res) => {
    const guides = await Guide.findAll()
    res.send(guides.toJSON())
})

guide_router.get("/", authenticateToken, async (req,res) => {
    const user = User.findOne({
        where: {
            email: req.email
        }
    })
    if (user)
    {
        console.log(user.OrganisationId)
        const orga = await Organisation.findByPk(user.OrganisationId)
        if (orga)
        {
            console.log(orga)
            res.send(orga.toJSON())
            const nodes = await Node.findAll({
                where: {
                    OrganisationId: orga.id
                }
            });
            let all_guides = [];
            for (const iterator of nodes) {
                const guides = await Guide.findAll({
                    where: {
                        NodeId: iterator.id
                    }
                });
                all_guides.push(guides);
            }
            return res.send(all_guides)
        }
    }
    res.status(401).send()
})

guide_router.get("/:id", authenticateToken, async (req, res) => {
    const guide = await Guide.findOne({
        where: {
          id: req.params.id
        }
      })
    
      if (guide)
      {
        res.send(guide.toJSON())
      } else {
        res.status(404).send("Guide not found")
      }
})

guide_router.post("/", authenticateToken, async (req, res) => {
    try {
  
        let guide = await Guide.create({
          text: req.body.text
        });
        res.send(guide.toJSON());
      } catch (err)
      {
        console.log(err);
        res.status(500).send("unexpected error");
      }
})

guide_router.patch("/", authenticateToken, async (req,res) => {
    const guide = await Guide.findOne({
        where: {
            id: req.body.id
        }
      });
      await guide.update({
          text: req.body.text || guide.text,
          NodeId: req.body.node || guide.NodeId
      })
      res.send(guide.toJSON())
})

guide_router.delete("/", authenticateToken, async (req, res) => {
    const guide = await Guide.findOne({
        where:{
          id: req.body.id
        }
      })
    
      if (guide)
      {
        guide.delete()
        res.send("success")
      } else {
        res.status(404).send("Guide not found");
      }
})

export default guide_router;