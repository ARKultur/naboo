import express from "express";
import User from "../db/models/Users.js"
import { generateAccessToken, authenticateToken, checkUser, authenticateTokenAdm} from '../utils.js';
import crypto from 'crypto'
import nodemailer from 'nodemailer'
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
 * /api/accounts/admin:
 *   get:
 *     security:
 *       - adminBearerAuth: [] 
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
 *   patch:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Edit an user organisation id
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
 *   delete:
 *     security:
 *       - adminBearerAuth: []
 *     summary: delete an user by id
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - id
 *            type: object
 *            properties:
 *              id:
 *                type: number
 *     responses:
 *       200:
 *         description: User succesfully deleted
 * /api/accounts:
 *   delete:
 *     security:
 *       - userBearerAuth: []
 *     summary: Delete the user account
 *     tags: [Users]
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
 *                  description: User succesfully deleted
 *       500:
 *         description: Some server error
 * 
 *   patch:
 *     security:
 *       - userBearerAuth: []
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
 * /api/accounts?email={email}:
 *   get:
 *     security:
 *       - userBearerAuth: []
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
 * /api/accounts/verification:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Request an email verification
 *     tags: [Users]
 *     responses:
 *       200:
 *        description: A confirmation string
 *        content:
 *          application/json:
 *            schema:
 *              type: string
 *       500:
 *         description: Internal server error
 * /api/accounts/confirm?token={token}:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Validates the token for the email
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: token
 *         schema:
 *           type: string
 *         required: true
 *         description: The email's verification token
 *     responses:
 *       200:
 *        description: A confirmation string
 *        content:
 *          application/json:
 *            schema:
 *              type: string
 *       500:
 *         description: Internal server error
 * /api/accounts/forgot:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Request a password reset
 *     tags: [Users]
 *     responses:
 *       200:
 *        description: A confirmation string
 *        content:
 *          application/json:
 *            schema:
 *              type: string
 *       500:
 *         description: Internal server error
 * /api/accounts/reset:
 *   post:
 *     summary: Reset the user password
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *              - token
 *              - password
 *              - new_password
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
 *         description: Confirmation string
 *         content:
 *           application/json:
 *             schema:
 *             type: string
 *       404:
 *         description: Password reset token not found or has expired.
 *       500:
 *         description: Internal server error
 */

const TOKEN_EXPIRATION_TIME = 24 * 60 * 60 * 1000;

account_router.get('/admin', authenticateTokenAdm, async (req, res) => {
    const users = await User.findAll({
    });
    res.send(users)
})


account_router.get('/', authenticateToken, async (req, res) => {
    try {
    const {email} = req.query
    const user = await User.findOne({
      where: {
        email: email
      }
    })
  
    if (user)
    {
      res.send(user.toJSON())
    } else {
      res.status(404).send("User not found")
    }
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

account_router.get('/forgot', authenticateToken, async (req, res) => {
    try {
	const token = crypto.randomBytes(20).toString('hex');
	const expirationDate = new Date(Date.now() + TOKEN_EXPIRATION_TIME);
	const user = await User.findOne({
	    where:{
		email: req.email
	    }
	})

	/* c8 ignore next 4 */
	if (!user)
	{
	    throw new Error('')
	}

	const transporter = nodemailer.createTransport({
	    service: 'gmail',
	    auth: {
		user: process.env.GMAIL_EMAIL,
		pass: process.env.GMAIL_PASSWORD
	    }
	});
	const confirmationLink = `${process.env.RESET_URL}?token=${token}`;
	const mailOptions = {
	    from: process.env.GMAIL_EMAIL,
	    to: req.email,
	    subject: 'Reset your password',
	    text: `Click the following link to reset your password: ${confirmationLink}`
	};

	/* c8 ignore next 6 */
	if (process.env.UT_CI == false)
	{
	    await transporter.sendMail(mailOptions);
	    await user.update({
		confirmationToken: token,
		confirmationTokenExpiration: expirationDate
	    })
	    return res.send('An email has been sent to your address with instructions for resetting your password.');
	} else if (process.env.UT_CI === 'true')
	{
	    await user.update({
	    confirmationToken: token,
	    confirmationTokenExpiration: expirationDate
	    })
	}
	res.send({ token: token})
    }/* c8 ignore next 5 */
    catch (err)
    {
	console.log(err)
	res.sendStatus(500)
    }
})

account_router.post('/reset', async (req, res) => {
    try {
	const { token, new_password } = req.body

	const user = await User.findOne({
	    where: {
		confirmationToken: token
	    }
	})

	if (!user || user.confirmationTokenExpiration < new Date())
	{
	    return res.status(404).send('Password reset token not found or has expired.');
	}

	await user.update({
	    password: new_password,
	    confirmationToken: null,
	    confirmationTokenExpiration: null
	})
	res.send('Password succesfully resetted')
    } catch (err)
    {
	console.log(err)
	res.sendStatus(500)
    }
})

account_router.get('/verification', authenticateToken, async (req, res) => {
    try {
	const token = crypto.randomBytes(20).toString('hex');
	const expirationDate = new Date(Date.now() + TOKEN_EXPIRATION_TIME);
	const user = await User.findOne({
	    where:{
		email: req.email
	    }
	})

	/* c8 ignore next 4 */
	if (!user)
	{
	    throw new Error('')
	}

	let val = {
		user: process.env.GMAIL_EMAIL,
		pass: process.env.GMAIL_PASSWORD
	}
	console.log(val)
	const transporter = nodemailer.createTransport({
	    service: 'gmail',
	    auth: val
	});
	const confirmationLink = `${process.env.CONFIRM_URL}?token=${token}`;
	const mailOptions = {
	    from: process.env.GMAIL_EMAIL,
	    to: req.email,
	    subject: 'Confirm Your Email',
	    text: `Click the following link to confirm your email: ${confirmationLink}`
	};

	/* c8 ignore next 6 */
	if (process.env.UT_CI === 'false')
	{
	    await transporter.sendMail(mailOptions);
	    await user.update({
	    confirmationToken: token,
	    confirmationTokenExpiration: expirationDate
	    })
	    return res.send('An email has been sent to your address with instructions for confirming your email.');
	} else if (process.env.UT_CI === 'true')
	{
	    await user.update({
	    confirmationToken: token,
	    confirmationTokenExpiration: expirationDate
	    })
	}
	res.send({ token: token})
    }/* c8 ignore next 5 */
    catch (err)
    {
	console.log(err)
	res.sendStatus(500)
    }
})

account_router.get('/confirm', authenticateToken, async (req, res) => {
    try {
	const { token } = req.query;
	
	const user = await User.findOne({
	    where:{
		email: req.email,
		confirmationToken: token
	    }
	})

	/* c8 ignore next 2 */
	if (!user)
	    res.status(404).send('No user found')
	
	if (user.email && user.confirmationTokenExpiration > new Date()) {
	    await user.update({
		isConfirmed: true,
		confirmationTokenExpiration: null,
		confirmationToken: null
	    })

	    res.send({ text: 'Your email has been confirmed.'});
	} else {
	    res.status(400).send('Invalid or expired confirmation link.');
	}
    } catch (err) {
	console.error(err)
	res.sendStatus(500)
    }
})

account_router.delete('/', authenticateToken, async (req, res) => {
    try {
  const user = await User.findOne({
    where:{
      email: req.email
    }
  })

  if (user)
  {
    await user.destroy()
    res.send("succesfully deleted")
  } else {
    res.status(404).send("User not found");
  }
    } catch (error)
    {
	console.error(error)
	res.sendStatus(500)
    }
})

account_router.delete('/admin', authenticateTokenAdm, async (req, res)=> {
    try {
	const user = await User.findOne({
	    where:{
		id: req.body.id
	    }
	})
	if (!user)
	    return res.status(404).send('User not found')
	await user.destroy();
	res.send("Succesfully deleted")
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
}) 

account_router.patch('/admin', authenticateTokenAdm, async (req, res) => {
	try {
  const user = await User.findOne({
    where: {
      email: req.body.email
    }
  });
  if (user) {
    await user.update({
      OrganisationId: req.body.OrganisationId || user.OrganisationId,
    })
    return res.send(user.toJSON())
  }
	} catch (err) {
  res.status(500).send("Unexpected error")
	}
})

account_router.patch('/', authenticateToken, async (req, res) => {
	try {
  const user = await User.findOne({
    where: {
      email: req.email
    }
  });
  if (user) {
    await user.update({
      username: req.body.username || user.username,
      password: req.body.password || user.password,
      addressId: req.body.address || user.addressId
    })
    return res.send(user.toJSON())
  }
	} catch (err) {
  res.status(500).send("Unexpected error")
	}
})

export default account_router;
