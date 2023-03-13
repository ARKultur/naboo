import express from "express";
import {Contact} from "../db/models/index.js";

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
 *        uuid: 798cb30f-8cca-4d25-bf5d-2fe933a29d90
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
 *   post:
 *     summary: Create a new contact request
 *     tags: [Contact]
 *     responses:
 *       200:
 *         description: Contact request successfully created
 *       400:
 *         description: Missing argument(s)
 *
 * /api/contact/{uuid}:
 *   patch:
 *     summary: Update a contact request
 *     tags: [Contact]
 *     responses:
 *       200:
 *         description: Contact request successfully updated
 *       400:
 *         description: Missing argument(s)
 *       404:
 *         description: Contact not found (wrong uuid)
 *   delete:
 *     summary: Delete a contact request
 *     tags: [Contact]
 *     responses:
 *       200:
 *         description: Contact request successfully deleted
 *       400:
 *         description: Missing argument(s) (uuid)
 *       404:
 *         description: Contact not found (wrong uuid)
 */

contact_router.post('/', async (req, res) => {
  try {
    const {name, category, description, email} = req.body;

    if (!(name && category && description && email))
      return res.status(400).send("Missing value")
    await Contact.create({
      name: name,
      category: category,
      description: description,
      email: email,
    })
    res.status(200).send("Contact successfully created");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
})

contact_router.patch('/:uuid', async (req, res) => {
  try {
    const uuid = req.params.uuid;
    const {name, email, processed} = req.body;

    if (!(name && processed && email && uuid))
      return res.status(400).send("Missing value")
    const contact = await Contact.findOne({
      where: {
        uuid: uuid,
      }
    });
    if (contact.length === 0)
      return res.status(404).send("Contact not found");
    await contact[0].update({
      name: name,
      email: email,
      processed: processed,
    })
    res.status(200).send("Contact successfully updated");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
})

contact_router.get('/', async (req, res) => {
  try {
    const contacts = await Contact.findAll();

    res.status(200).send(contacts);
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
})

contact_router.delete('/:uuid', async (req, res) => {
  try {
    const uuid = req.params.uuid;

    if (!uuid)
      return res.status(400).send("Missing arguments");
    const contact = await Contact.findOne({
      where: {
        uuid: uuid,
      }
    });
    if (contact.length === 0)
      return res.status(404).send("Contact not found");
    await contact[0].destroy();
    res.status(200).send("Contact successfully deleted");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
})

export default contact_router;