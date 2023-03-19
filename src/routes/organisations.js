import express from "express";
import User from "../db/models/Users.js"
import Organisation from "../db/models/Organisations.js";
import { authenticateToken, authenticateTokenAdm} from '../utils.js';
 
const orga_router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Organisation:
 *       type: object
 *       required:
 *         - name
 *       properties:
 *         id:
 *           type: integer
 *           description: The auto-generated id of the organisation
 *         name:
 *           type: string
 *           description: The organisation's name
 *         addressId:
 *           type: integer
 *           description: The referenced address's id
 *       example:
 *         id: 12
 *         name: ARKultur
 *         addressId: 5
 */

/**
 * @swagger
 * tags:
 *   name: Organisations
 *   description: The Organisations managing API
 * /api/organisations:
 *   post:
 *     summary: Create a Organisation
 *     tags: [Organisations]
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
 *     responses:
 *       200:
 *         description: The created Organisation
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Organisation'
 *       500:
 *         description: Organisation already existing
 *   patch:
 *     summary: Edit a Organisation
 *     tags: [Organisations]
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
 *              address:
 *                type: integer
 *              new_name:
 *                type: string
 *     responses:
 *       200:
 *         description: The edited Organisation
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Organisation'
 *       404:
 *         description: Organisation not found
 * 
 *   delete:
 *     summary: Delete a Organisation
 *     tags: [Organisations]
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
 *         description: Organisation not found
 *   get:
 *     summary: Lists all the Organisations
 *     tags: [Organisations]
 *     responses:
 *       200:
 *         description: The list of the Organisations
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Organisation'
 * 
 */

orga_router.get('/', authenticateTokenAdm, async (req, res) => {
  const orgas = await Organisation.findAll();  
  res.send(orgas);
})

orga_router.post('/', authenticateTokenAdm, async (req, res) => {
  
    try {
      const orga = await Organisation.create({
        name: req.body.name
      })
      res.send(orga);  
    } catch (error) {
      res.status(401).send("name already taken");
    }
})
  
orga_router.patch('/', authenticateTokenAdm, async (req, res) => {
    try {
    const orga = await Organisation.findOne({
      where: {
        name: req.body.name
      }
    });
    if (orga)
    {
      await orga.update({
        name: req.body.new_name || orga.name,
        addressId: req.body.address || orga.addressId
      })
      
      res.send(orga);
    } else {
      res.status(404).send("Organisation not found");
    }
    } catch (err)
    {
	res.sendStatus(500);
    }
})
  
orga_router.delete('/', authenticateTokenAdm, async (req, res) => {
    try {
    const orga = await Organisation.findOne({
      where: {
        name: req.body.name
      }
    })
  
    if (orga)
    {
      await orga.destroy()
      res.send("success")
    } else {
      res.status(404).send("Organisation not found");
    }
    } catch (err)
    {
	res.sendStatus(500)
    }
})

export default orga_router;
