import express from "express";
import Orb from "../db/models/Orb.js";
import {authenticateTokenAdm} from "../utils.js";

/**
 * @swagger
 * components:
 *  schemas:
 *    OrbData:
 *      type: object
 *      required:
 *        - descriptors
 *        - keypoints
 *      properties:
 *        keypoints:
 *          type: string
 *          description: the keypoints of the orb
 *        descriptors:
 *          type: string
 *          description: the descriptors of the orb
 *      example:
 *        image_id: 10
 *        keypoints: xxxx
 *        descriptors: xxxx
 */

const orb_router = express.Router();

/**
 * @swagger
 * tags:
 *  name: Orb
 *  description: Api for orb
 * /api/orb:
 *   post:
 *     summary: Create a new orb data
 *     tags: [Orb]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             required:
 *               - descriptors
 *               - keypoints
 *             type: object
 *             properties:
 *               descriptors:
 *                 type: string
 *               keypoints:
 *                 type: string
 *     responses:
 *       200:
 *         description: Orb successfully created
 *       400:
 *         description: Missing argument(s)
 *       500:
 *         description: Internal server error
 *
 * /api/orb/{uuid}:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Get an orb
 *     tags: [Orb]
 *     responses:
 *       200:
 *         description: the requested orb
 *       404:
 *         description: Orb not found
 *       500:
 *         description: Internal server error
 */

orb_router.post('/', authenticateTokenAdm, async (req, res) => {
  try {
    const { keypoints, descriptors } = req.body;

    if (!keypoints || !descriptors) {
      return res.status(400).json({ error: 'Key points and descriptors are required' });
    }

    const orbData = await Orb.create({
      keypoints: JSON.stringify(keypoints),
      descriptors: JSON.stringify(descriptors),
    });

    res.status(201).json({ image_id: orbData.id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


orb_router.get('/admin', async (req, res) => {
    try {
	const orbs = await Orb.findAll();
	res.send(orbs);
    } catch (error)
    {
	console.log(error)
	res.status(500).json({error: "Unexpected error"});
    }
})

orb_router.get('/:id', authenticateTokenAdm, async (req, res) => {
  try {
    const { id } = req.params;
    const orbData = await Orb.findByPk(id);

    if (!orbData) {
      return res.status(404).json({ error: 'Data not found' });
    }

    res.json({
      image_id: orbData.id,
      keypoints: JSON.parse(orbData.keypoints),
      descriptors: JSON.parse(orbData.descriptors),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

orb_router.delete('/', async (req, res) => {
  try {
    const { id } = req.body;
    const orbData = await Orb.findByPk(id);

    if (!orbData) {
      return res.status(404).json({ error: 'Data not found' });
    }
      await orbData.delete();
      res.json({success: true});
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

orb_router.patch('/', authenticateTokenAdm, async (req, res) => {

    try {
	const {id} = req.body
	const OrbData = await Orb.findByPk(id);
	if (OrbData) {
	    await OrbData.update({
		checkpoints: req.body.checkpoints || user.checkpoints,
		descriptors: req.body.descriptors || user.descriptors
	    })
	    return res.send(OrbData.toJSON())
	}
    } catch (e) {
	res.status(500).send("Unexpected error")
    }
})

export default orb_router;
