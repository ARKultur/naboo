import express from "express";
import User from "../db/models/Users.js"
import { generateAccessToken, authenticateToken, checkUser, authenticateTokenAdm} from '../utils.js';
 
/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       required:
 *         - username
 *         - email
 *         - password
 *       properties:
 *         id:
 *           type: integer
 *           description: The auto-generated id of the user
 *         username:
 *           type: string
 *           description: The username of the user
 *         email:
 *           type: string
 *           description: The email of the user
 *         password:
 *           type: string
 *           description: The password of the user
 *         addressId:
 *           type: integer
 *           description: The id of the referenced Address
 *         OrganisationId:
 *           type: integer
 *           description: tge id of the referenced Organisation
 *       example:
 *         id: 12
 *         username: jaj
 *         email: smthing@smh.com
 *         password: password
 *         addressId: 5
 *         OrganisationId: 2
 */

const account_router = express.Router();


/**
 * @swagger
 * tags:
 *   name: Users
 *   description: The Users managing API
 * /api/accounts:
 *   get:
 *     summary: Lists all the Users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: The list of the Users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *   delete:
 *     summary: Delete an user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/User'
 *     responses:
 *       200:
 *         description: 'Confirmation string'
 *         content:
 *          application/json:
 *            schema:
 *              type: object
 *              properties:
 *                confirmation:
 *                  type: string
 *                  description: Test
 *       500:
 *         description: Some server error
 * 
 *   patch:
 *     summary: Edit an user
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            $ref: '#/components/schemas/User'
 *     responses:
 *       200:
 *         description: The edited user.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 *       500:
 *         description: Some server error
 * 
 * /api/accounts/{username}:
 *   get:
 *     summary: Get the user by the username
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: username
 *         schema:
 *           type: string
 *         required: true
 *         description: The user's username
 *     responses:
 *       200:
 *        description: The user response by username
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/User'
 *       404:
 *         description: User not found
 */

account_router.get('/', authenticateTokenAdm, async (req, res) => {
    const users = await User.findAll({
    });
    res.send(users)
})

account_router.get('/:username', authenticateToken, async (req, res) => {
    const user = await User.findOne({
      where: {
        username: req.params.username
      }
    })
  
    if (user)
    {
      res.send(user.toJSON())
    } else {
      res.status(404).send("User not found")
    }
})

account_router.delete('/', authenticateToken, async (req, res) => {
  const user = await User.findOne({
    where:{
      email: req.body.email
    }
  })

  if (user)
  {
    user.delete()
    res.send("succesfully deleted")
  } else {
    res.status(404).send("User not found");
  }
})

account_router.patch('/', authenticateToken, async (req, res) => {
  const user = await User.findOne({
    where: {
      email: req.email
    }
  });
  if (user) {
    await user.update({
      username: req.body.username || user.username,
      password: req.body.password || user.password,
      addressId: req.body.address || user.addressId,
      OrganisationId: req.body.organisation || user.OrganisationId
    })
    return res.send(user.toJSON())
  }
  res.status(500).send("Unexpected error")
})

export default account_router;