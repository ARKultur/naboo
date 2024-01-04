import express from "express";
//import {Contact} from "../db/models/index.js";
import {authenticateTokenAdm} from "../utils.js";

import prisma from '../db/prisma.js'

/**
 * @swagger
 * components:
 *  schemas:
 *    Contact:
 *      type: object
 *      required:
 *        - name
 *        - category
 *        - description
 *        - email
 *      properties:
 *        uuid:
 *          type: string
 *          description: Auto generated uuid for each new contact
 *        name:
 *          type: string
 *          description: Name of the person who contact us
 *        category:
 *          type: string
 *          description: Type of the request (user experience, bugs report, ....)
 *        description:
 *          type: string
 *          description: Details about the request
 *        email:
 *          type: string
 *          description: Email of the person that allow us to respond to the request
 *        processed:
 *          type: boolean
 *          description: Allow to know if the request has been processed or not
 *      example:
 *        uuid: 00000000-0000-0000-0000-000000000000
 *        name: John Doe
 *        category: Bugs Report
 *        description: Lorem ipsum dolor sit amet, consectetur adipiscing elit.
 *        email: example@example.com
 *        processed: false
 */

const contact_router = express.Router();

/**
 * @swagger
 * tags:
 *  name: Contact
 *  description: Api for contact
 * /api/contact:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Get all contact request
 *     tags: [Contact]
 *     responses:
 *       200:
 *         description: The list of all contact request
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Contact'
 *       500:
 *         description: Internal server error
 *   post:
 *     summary: Create a new contact request
 *     tags: [Contact]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             required:
 *              - name
 *              - category
 *              - description
 *              - email
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               category:
 *                 type: string
 *               description:
 *                 type: string
 *               email:
 *                 type: string
 *     responses:
 *       200:
 *         description: Contact request successfully created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               items:
 *                 $ref: '#/components/schemas/Contact'
 *       400:
 *         description: Missing argument(s)
 *       500:
 *         description: Internal server error
 *
 * /api/contact/{uuid}:
 *   patch:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Update a contact request
 *     tags: [Contact]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             required:
 *               - name
 *               - email
 *               - processed
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               processed:
 *                 type: boolean
 *     parameters:
 *       - name: uuid
 *         in: path
 *         description: Uuid of the request
 *         required: true
 *         items:
 *           type: string
 *     responses:
 *       200:
 *         description: Contact request successfully updated
 *       400:
 *         description: Missing argument(s)
 *       404:
 *         description: Contact not found (wrong uuid)
 *       500:
 *         description: Internal server error
 *   delete:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Delete a contact request
 *     tags: [Contact]
 *     parameters:
 *       - name: uuid
 *         in: path
 *         description: Uuid of the request
 *         required: true
 *         items:
 *           type: string
 *     responses:
 *       200:
 *         description: Contact request successfully deleted
 *       400:
 *         description: Missing argument(s) (uuid)
 *       404:
 *         description: Contact not found (wrong uuid)
 *       500:
 *         description: Internal server error
 */

contact_router.post('/', async (req, res) => {
    try {
	const {name, category, description, email} = req.body;

	if (!(name && category && description && email))
	    return res.status(400).send("Missing value")

	/*
	await Contact.create({
	    name: name,
	    category: category,
	    description: description,
	    email: email,
	    })
	*/
	const contact = await prisma.contact.create({
	    data: {
		name: name,
		category: category,
		description: description,
		email: email
	    }
	})
	res.status(200).send(contact);
    } catch (error) {
	console.log(error);
	res.status(500).send("Internal Error");
    }
})

contact_router.patch('/:uuid', authenticateTokenAdm, async (req, res) => {
    try {
	const uuid = parseInt(req.params.uuid);
	const {name, email, processed} = req.body;

	if (!(name && processed && email && uuid))
	    return res.status(400).send("Missing value")
	/*
	const contact = await Contact.findOne({
	    where: {
		uuid: uuid,
	    }
	});
	*/
	const contact = await prisma.contact.findUnique({
	    where: {
		uuid: uuid
	    }
	})
	if (!contact)
	    return res.status(404).send("Contact not found");
	/*
	await contact.update({
	    name: name,
	    email: email,
	    processed: processed,
	})
	*/
	await prisma.contact.update({
	    where: {
		uuid: uuid
	    },
	    data: {
		name: name,
		email: email,
		processed: processed
	    }
	})
	res.status(200).send("Contact successfully updated");
    } catch (error) {
	console.log(error);
	res.status(500).send("Internal Error");
    }
})

contact_router.get('/', authenticateTokenAdm, async (req, res) => {
  try {
    //const contacts = await Contact.findAll();
      const contacts = await prisma.contact.findMany();
    res.status(200).send(contacts);
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
})

contact_router.delete('/:uuid', authenticateTokenAdm, async (req, res) => {
    try {
	const uuid = req.params.uuid;

	if (!uuid)
	    return res.status(400).send("Missing arguments");
	/*
	const contact = await Contact.findOne({
	    where: {
		uuid: uuid,
	    }
	});
	*/
	const contact = await prisma.contact.delete({
	    where: {
		uuid: uuid
	    }
	})
	if (!contact)
	    return res.status(404).send("Contact not found");

	//await contact.destroy();
	res.status(200).send("Contact successfully deleted");
    } catch (error) {
	console.log(error);
	res.status(500).send("Internal Error");
    }
})

export default contact_router;
