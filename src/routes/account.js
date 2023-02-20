import express from "express";
import User from "../db/models/Users.js"
import { generateAccessToken, authenticateToken, checkUser } from '../utils.js';
 
const account_router = express.Router();

account_router.get('/', authenticateToken, async (req, res) => {
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
      email: req.email
    }
  })

  if (user)
  {
    user.delete()
  } else {
    res.status(404).send("User not found");
  }
})

account_router.patch('/', authenticateToken, async (req, res) => {
  const user = await User.findAll({
    where: {
      email: req.email
    }
  })[0];
  await user.update({
    username: req.body.username || user.username,
    password: req.body.password || user.password
  })
  res.send(user)
})

export default account_router;