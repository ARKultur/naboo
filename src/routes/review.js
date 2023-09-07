import express from "express";
import prisma from '../db/prisma.js'
import { authenticateToken, authenticateTokenAdm} from '../utils.js';

let review_router = express.Router()

/**
 * @swagger
 * components:
 *   schemas:
 *     Review:
 *       type: object
 *       required:
 *        - title
 *        - description
 *       properties:
 *         title:
 *           type: string
 *           description: The guide's title
 *         description:
 *           type: string
 *           description: The guide's description
 *         keywords:
 *           type: string[]
 *           description: The guide's keywords
 *         openingHours:
 *           type: string[]
 *           description: The guide's opening hours
 *         website:
 *           type: string
 *           description: The guide's website
 *         priceDesc:
 *           type: string[]
 *           description: List of the guide's price title (need value)
 *         priceValue:
 *           type: string[]
 *           description: List of the guide's price value (need description)
 */

review_router.post("/:guideId", authenticateToken, async (req, res) => {
  try {
    const user = await prisma.user.findFirst({
      where: { email: req.email }
    })
    const review = await prisma.review.create({
      data: {
        stars: req.body.stars,
        message: req.body.message,
        guideId: parseInt(req.params.guideId),
        userId: user.id,
      }
    })
    res.json(review);
  }
  catch (err) {
    console.log(err);
    res.status(500).send("unexpected error");
  }
})

review_router.get("/:id", authenticateToken, async (req, res) => {
  try {
    const review = await prisma.review.findUnique({
      where: {
        guideId: parseInt(req.params.id)
      }
    })
    if (!review || review == null)
    {
        return res.status(404).json({error: "Review not found"})
    }
    res.json(review)
  }
  catch (err) {
    console.log('error: ', err)
    res.sendStatus(500)
  }
})

export default review_router;
