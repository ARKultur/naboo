import express from "express";

import {Customer} from '../db/models/index.js'

import { authenticateToken, authenticateTokenAdm, checkCustomer} from '../utils.js';

const customer_router = express.Router();

customer_router.post("/login", async (req, res) => {
    try {
        const user = await checkCustomer(req.body.email, req.body.password) || await checkAdmin(req.body.email, req.body.password)
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

customer_router.post("/register", async (req, res) => {
    try {
  
        let customer = await Customer.create({
          username: req.body.username,
          password: req.body.password,
          email: req.body.email
        });
        res.send(customer.toJSON());
      } catch (err)
      {
        console.log(err);
        res.status(401).send("email or username already taken");
      }
})

customer_router.get('/', authenticateTokenAdm, async (req, res) => {
    const customers = await Customer.findAll();

    res.send(customers)
})

customer_router.get("/:id", authenticateToken, async (req, res) => {
    const customer = await Customer.findByPk(req.params.id)

    if (customer)
    {
        return res.send(customer.toJSON())
    }
    res.status(404).send("Customer not found")
})

customer_router.post("/", authenticateTokenAdm, async (req, res) => {
    try {
        
        let customer = await Customer.create({
          username: req.body.username,
          password: req.body.password,
          email: req.body.email
        });
        res.send(customer.toJSON());
      } catch (err)
      {
        console.log(err);
        res.status(401).send("email or username already taken");
      }
})

customer_router.post("/:id", authenticateToken, async (req,res) => {

})

export default customer_router;