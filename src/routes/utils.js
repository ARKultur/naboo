import express from "express";
import { generateAccessToken, authenticateToken, checkUser, checkAdmin} from '../utils.js';
import {User} from '../db/models/index.js'

const utils_router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Utils
 *   description: The Utility API
 * /api/login:
 *   post:
 *     summary: Logs in as an user or administrator
 *     tags: [Utils]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *              - email
 *              - password
 *            type: object
 *            properties:
 *              email:
 *                type: string
 *              password:
 *                type: string
 *     responses:
 *       200:
 *         description: The bearer token.
 *         content:
 *           application/json:
 *             schema:
 *               required:
 *                 - token
 *               type: object
 *               properties:
 *                 token:
 *                  type: string
 *       401:
 *         description: Invalid credentials
 * 
 * /api/signin:
 *   post:
 *     summary: Register as an user
 *     tags: [Utils]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *              - email
 *              - password
 *              - username
 *            type: object
 *            properties:
 *              email:
 *                type: string
 *              password:
 *                type: string
 *              username:
 *                type: string
 *     responses:
 *       200:
 *         description: The registered user.
 *         content:
 *           application/json:
 *             schema:
 *              $ref: '#/components/schemas/User'
 *       401:
 *         description: Email or username already taken
 */

utils_router.post('/logout', authenticateToken, (req, res, next) => {
    res.send("work in progress");
})

utils_router.post('/login', async (req, res) => {

    try {
      const user = await checkUser(req.body.email, req.body.password) || await checkAdmin(req.body.email, req.body.password)
      if (user)
      {
        const token = generateAccessToken(req.body.email);
      
        res.json(token);
      } else
      {
        res.status(401).send("invalid credentials");  
      }
    } catch (error) {
      res.status(401).send("invalid credentials");  
    }
})

utils_router.post('/signin', async (req, res) => {
    try {
  
      let user = await User.create({
        username: req.body.username,
        password: req.body.password,
        email: req.body.email
      });
      res.send(user);
    } catch (err)
    {
      console.log(err);
      res.status(401).send("email or username already taken");
    }
})

export default utils_router;