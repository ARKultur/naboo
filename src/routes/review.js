import express from "express";
import prisma from '../db/prisma.js'
import { authenticateToken} from '../utils.js';

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

review_router.get("/", authenticateToken, async (req, res) => {
  const review = await prisma.review.findMany({
    where: {
      id: req.query.id ? req.query.id : undefined,
      guideId: req.query.guideId ? parseInt(req.query.guideId) : undefined,
    }
  })
  res.json(review)
})

review_router.patch("/:id", authenticateToken, async (req,res) => {
  const review = await prisma.review.findUnique({
      where: {
          id: req.params.id
      }
  })

  if (!review)
      return res.status(404).send("Review not found")
  const new_review = await prisma.review.update({
      where: {
          id: review.id
      },
      data: {
          stars: req.body.stars || review.stars,
          message: req.body.message || review.message,
      }
  })
  res.json(new_review)
})

review_router.delete("/:id", authenticateToken, async (req, res) => {
  const deleted = await prisma.review.delete({
      where: {
          id: req.params.id
      }
  })

  if (!deleted)
      return res.status(404).send("Review not found")
  res.send("success")
})

review_router.get("/:id", authenticateToken, async (req, res) => {
  try {
    const review = await prisma.review.findFirst({
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
    console.log(err)
    res.sendStatus(500)
  }
})

export default review_router;
