import express from "express";

//import {Customer} from '../db/models/index.js'

import prisma from "../db/prisma.js";

import {
  authenticateToken,
  authenticateTokenAdm,
  checkCustomer,
  generateAccessToken,
  authenticateTokenCustomer,
} from "../utils.js";

/**
 * @swagger
 * components:
 *   schemas:
 *     Customer:
 *       type: object
 *       required:
 *         - username
 *         - email
 *         - password
 *         - first_name
 *         - last_name
 *         - phone_number
 *       properties:
 *         id:
 *           type: integer
 *           description: The auto-generated id of the customer
 *         username:
 *           type: string
 *           description: The username of the customer
 *         email:
 *           type: string
 *           description: The email of the customer
 *         password:
 *           type: string
 *           description: The password of the customer
 *         addressId:
 *           type: integer
 *           description: The id of the referenced Address
 *         first_name:
 *           type: string
 *           description: The first name of the customer
 *         last_name:
 *           type: string
 *           description: The last name of the customer
 *         phone_number:
 *           type: string
 *           description: The phone number of the customer
 *       example:
 *         id: 12
 *         username: jaj
 *         email: smthing@smh.com
 *         password: password
 *         addressId: 5
 *         first_name: Axelle
 *         last_name: Whound
 *         phone_number: 06-55-55-55-55
 */

const customer_router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Customers
 *   description: The Customers managing API
 * /api/customers/admin:
 *   get:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Lists all the Customers
 *     tags: [Customers]
 *     responses:
 *       200:
 *         description: The list of the Customers
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Customer'
 * /api/customers/login:
 *   post:
 *     summary: Logs in as a customer
 *     tags: [Customers]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - email
 *             - password
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
 * /api/customers/register:
 *   post:
 *     summary: Register as a customer
 *     tags: [Customers]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            required:
 *             - email
 *             - password
 *             - username
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
 *         description: The registered customer.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Customer'
 *       401:
 *         description: Email or username already taken
 * /api/customers/all:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Lists all the Customers
 *     tags: [Customers]
 *     responses:
 *       200:
 *         description: The list of the Customers
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Customer'
 * /api/customers?email={email}:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Get the customer by the email
 *     tags: [Customers]
 *     parameters:
 *       - in: path
 *         name: email
 *         schema:
 *           type: string
 *         required: true
 *         description: The customer's email
 *     responses:
 *       200:
 *        description: The customer's data
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/User'
 *       404:
 *         description: customer not found
 * /api/customers:
 *   post:
 *     security:
 *       - adminBearerAuth: []
 *     summary: Create a customer
 *     tags: [Customers]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *            $ref: '#/components/schemas/Customer'
 *     responses:
 *       200:
 *         description: The created customer.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Customer'
 *       500:
 *         description: Some server error
 *
 * /api/customers/{id}:
 *   get:
 *     security:
 *       - userBearerAuth: []
 *     summary: Get the Customer by id
 *     tags: [Customers]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: The customer's id
 *     responses:
 *       200:
 *        description: The Customer response by id
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Customer'
 *       404:
 *         description: Customer not found
 *   post:
 *     security:
 *       - userBearerAuth: []
 *     summary: WIP
 *     tags: [Customers]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: The customer's id
 *     responses:
 *       200:
 *        description: WIP
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Customer'
 *       404:
 *         description: Customer not found
 */

customer_router.post("/login", async (req, res) => {
  try {
    const user = await checkCustomer(req.body.email, req.body.password);
    //console.log(user)

    if (user) {
      const token = generateAccessToken(req.body.email);
      res.json(token);
    } else {
      res.status(401).send("invalid credentials");
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

customer_router.post("/register", async (req, res) => {
  try {
    /*
        let customer = await Customer.create({
          username: req.body.username,
          password: req.body.password,
          email: req.body.email
          });
	*/
    const customer = await prisma.customers.create({
      data: {
        username: req.body.username,
        password: req.body.password,
        email: req.body.email,
      },
    });
    res.json(customer);
  } catch (err) {
    console.log(err);
    res.status(401).send("email or username already taken");
  }
});

customer_router.get("/admin", authenticateTokenAdm, async (req, res) => {
  //const customers = await Customer.findAll();
  const customers = await prisma.customers.findMany();
  res.send(customers);
});

customer_router.patch("/admin/:id", authenticateTokenAdm, async (req, res) => {
  try {
    const customer = await prisma.customers.findFirst({
      where: {
        id: req.body.id,
      },
    });
    if (customer) {
      const updated_customer = await prisma.customers.update({
        where: {
          id: customer.id,
        },
        data: {
          username: req.body.username || customer.username,
          password: req.body.password || customer.password,
          first_name: req.body.first_name || customer.first_name,
          last_name: req.body.last_name || customer.last_name,
          phone_number: req.body.phone_number || customer.phone_number,
        },
      });
      return res.send(updated_customer);
    }
  } catch (err) {
    res.status(500).send("Unexpected error");
  }
});

/* c8 ignore next 26 */
customer_router.patch("/", authenticateTokenCustomer, async (req, res) => {
  try {
    const customer = await prisma.customers.findFirst({
      where: {
        email: req.email,
      },
    });
    if (customer) {
      const updated_customer = await prisma.customers.update({
        where: {
          id: customer.id,
        },
        data: {
          username: req.body.username || customer.username,
          password: req.body.password || customer.password,
          first_name: req.body.first_name || customer.first_name,
          last_name: req.body.last_name || customer.last_name,
          phone_number: req.body.phone_number || customer.phone_number,
          likedSuggestions:
            req.body.likedSuggestions || customer.likedSuggestions,
        },
      });
      return res.send(updated_customer);
    }
  } catch (err) {
    res.status(500).send("Unexpected error");
  }
});

customer_router.get("/all", authenticateToken, async (req, res) => {
  //const customers = await Customer.findAll();
  const customers = await prisma.customers.findMany();
  res.send(customers);
});

customer_router.get("/", authenticateTokenCustomer, async (req, res) => {
  try {
    const email = req.email;
    /*
	const customer = await Customer.findOne({
	    where: {
		email: email
	    }
	})
	*/
    const customer = await prisma.customers.findUnique({
      where: {
        email: email,
      },
    });
    if (customer) {
      res.json(customer);
    } else {
      res.status(404).send("Customer not found");
    }
  } catch (error) {
    console.error(error);
    res.sendStatus(500);
  }
});

customer_router.post("/", authenticateTokenAdm, async (req, res) => {
  try {
    /*
        let customer = await Customer.create({
          username: req.body.username,
          password: req.body.password,
          email: req.body.email
          });
	*/
    const customer = await prisma.customers.create({
      data: {
        username: req.body.username,
        password: req.body.password,
        email: req.body.email,
      },
    });
    res.json(customer);
  } catch (err) {
    console.log(err);
    res.status(401).send("email or username already taken");
  }
});

customer_router.post("/:id", authenticateToken, async (req, res) => {});

export default customer_router;
