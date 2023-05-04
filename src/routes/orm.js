import express from "express";
import Orm from "../db/models/Orm.js";
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
 *        image_id:
 *          type: integer
 *          description: Auto generated id for each new orb data
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

const orm_router = express.Router();

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

orm_router.post('/', authenticateTokenAdm, async (req, res) => {
  try {
    const { keypoints, descriptors } = req.body;

    if (!keypoints || !descriptors) {
      return res.status(400).json({ error: 'Key points and descriptors are required' });
    }

    const orbData = await Orm.create({
      keypoints: JSON.stringify(keypoints),
      descriptors: JSON.stringify(descriptors),
    });

    res.status(201).json({ image_id: orbData.image_id });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

orm_router.get('/:image_id', authenticateTokenAdm, async (req, res) => {
  try {
    const { image_id } = req.params;
    const orbData = await Orm.findByPk(image_id);

    if (!orbData) {
      return res.status(404).json({ error: 'Data not found' });
    }

    res.json({
      image_id: orbData.image_id,
      keypoints: JSON.parse(orbData.keypoints),
      descriptors: JSON.parse(orbData.descriptors),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

orm_router.delete('/', async (req, res) => {
  try {
    const { image_id } = req.body;
    const orbData = await Orm.findByPk(image_id);

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

orm_router.patch('/', authenticateTokenAdm, async (req, res) => {

    try {
	const {image_id} = req.body
	const OrbData = await Orm.findOne({
	    where: {
		image_id: image_id
	    }
	});
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


export default orm_router;
