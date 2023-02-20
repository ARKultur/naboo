import express from "express";
import { generateAccessToken, authenticateToken, checkUser, checkAdmin} from '../utils.js';
import {User} from '../db/models/index.js'

const utils_router = express.Router();

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