import express from "express";
import { generateAccessToken, authenticateToken, checkUser, checkAdmin, isEmpty} from '../utils.js';
import {User} from '../db/models/index.js'
import path from 'path';
const __dirname = path.resolve();

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
 * /api/apk:
 *   get:
 *     summary: Download a file
 *     tags: [Utils]
 *     description: Initiates a file download to the client's machine when accessed.
 *     responses:
 *       200:
 *         description: File download initiated successfully
 *         content:
 *           application/octet-stream:
 *             schema:
 *               type: string
 *               format: binary
 *       500:
 *         description: Error downloading the file
 *         content:
 *           text/plain:
 *             schema:
 *               type: string
 */


utils_router.post('/logout', authenticateToken, (req, res, next) => {
    res.send("work in progress");
})

utils_router.post('/login', async (req, res) => {

    try {
	const user = await checkUser(req.body.email, req.body.password) || await checkAdmin(req.body.email, req.body.password)
	if (!isEmpty(user))
	{
            const token = generateAccessToken(req.body.email);
      
            res.json(token);
	} else
	{
	     throw new Error("")
	}
    } catch (error) {
      res.status(401).send("invalid credentials");  
    }
})

utils_router.post('/signin', async (req, res) => {
    try {
	if (!(req.body.email) || !(req.body.email) || !(req.body.password))
	    throw new Error("")
      let user = await User.create({
        username: req.body.username,
        password: req.body.password,
        email: req.body.email
      });
      res.send(user);
    } catch (err)
    {
	res.status(401).json("email or username already taken");
    }
})

utils_router.get('/apk', (req, res) => {
    try {
    const filePath = `${__dirname}/files/example.txt`;
    res.download(filePath, (err) => {
        if (err) {
            console.log('Error:', err);
            res.status(500).send('Error downloading the file');
        } else {
            console.log('File download initiated successfully');
        }
    });
    } catch (error)
    {
	console.error(500)
	res.sendStatus(500)
    }
});

utils_router.get('/ping', (req, res) => {
    try {
	const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress 
	console.log(ip)
	res.json({ip: ip})
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
});

export default utils_router;
