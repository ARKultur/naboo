import express from "express";
import Orb from "../db/models/Orb.js";
import {authenticateTokenAdm} from "../utils.js";

/**
 * @swagger
 * components:
 *   schemas:
 *     OrbData:
 *       type: object
 *       required:
 *         - keypoints
 *         - descriptors
 *       properties:
 *         image_id:
 *           type: integer
 *           description: Unique identifier for the image.
 *         keypoints:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               x:
 *                 type: integer
 *               y:
 *                 type: integer
 *               size:
 *                 type: integer
 *               angle:
 *                 type: number
 *               response:
 *                 type: number
 *               octave:
 *                 type: integer
 *           description: Array of keypoints detected in the image.
 *         descriptors:
 *           type: array
 *           items:
 *             type: array
 *             items:
 *               type: integer
 *           description: Array of descriptors corresponding to the keypoints.
*/

const orb_router = express.Router();

/**
 * @swagger
 * tags:
 *  name: Orb
 *  description: Api for orb
 * /api/orb:
 *   post:
 *     security:
 *       - adminBearerAuth: []
 *     tags: [Orb]
 *     summary: Store ORB data
 *     description: Store keypoints and descriptors for an image.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               keypoints:
 *                 $ref: '#/components/schemas/OrbData/properties/keypoints'
 *               descriptors:
 *                 $ref: '#/components/schemas/OrbData/properties/descriptors'
 *     responses:
 *       201:
 *         description: ORB data successfully stored.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 image_id:
 *                   $ref: '#/components/schemas/OrbData/properties/image_id'
 *       400:
 *         description: Bad request, keypoints and descriptors are required.
 *       500:
 *         description: Internal server error.
 *
 * /api/orb/{id}:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     tags: [Orb]
 *     description: Retrieve keypoints and descriptors for an image by id.
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: Unique identifier for the image.
 *     responses:
 *       200:
 *         description: ORB data retrieved successfully.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/OrbData'
 *       404:
 *         description: Data not found.
 *       500:
 *         description: Internal server error.
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
