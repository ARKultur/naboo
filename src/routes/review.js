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
 *        - stars
 *        - message
 *        - guideId
 *        - userId
 *       properties:
 *         stars:
 *           type: int
 *           description: The review note (between 1 and 5)
 *         message:
 *           type: string
 *           description: The review text
 *         guideId:
 *           type: int
 *           description: The review's target guide
 *         userId:
 *           type: int
 *           description: The review's editor
 */

/**
 * @swagger
 * tags:
 *   name: Guides
 *   description: The Guides managing API
 * /api/review/:guideId:
 *   post:
 *     security:
 *       - userBearerAuth: []
 *     summary: Create a review
 *     tags: [Review]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *              - stars
 *              - message
 *              - guideId
 *              - userId
 *            type: object
 *            properties:
 *              stars:
 *                type: int
 *              message:
 *                type: string
 *              userId:
 *                type: int
 *     responses:
 *       200:
 *         description: The created review
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Review'
 *       500:
 *         description: Unexpected error
 *
 * /api/review:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Create a review
 *     tags: [Review]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            type: object
 *            properties:
 *              stars:
 *                type: int
 *              message:
 *                type: string
 *              guideId:
 *                type: int
 *              userId:
 *                type: int
 *     responses:
 *       200:
 *         description: The created review
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Review'
 *       500:
 *         description: Unexpected error
 *
 *   patch:
 *     security:
 *       - userBearerAuth: []
 *     summary: Create a review
 *     tags: [Review]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *              - stars
 *              - message
 *              - guideId
 *              - userId
 *            type: object
 *            properties:
 *              stars:
 *                type: int
 *              message:
 *                type: string
 *              guideId:
 *                type: int
 *              userId:
 *                type: int
 *     responses:
 *       200:
 *         description: The created review
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Review'
 *       500:
 *         description: Unexpected error
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

export default review_router;
