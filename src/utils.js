import jwt from 'jsonwebtoken';
import express from 'express'
import {User} from './db/models/index.js'

function generateAccessToken(username) {
    return jwt.sign({username}, process.env.TOKEN_SECRET, { expiresIn: "1h" });
}

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization']
    const token = authHeader && authHeader.split(' ')[1]

  
    if (token == null) return res.sendStatus(401)
  
    jwt.verify(token.toString(), process.env.TOKEN_SECRET, (err, user) => {
  
      if (err) return res.sendStatus(403)
  
      req.email = user.username
  
      next()
    })
}

async function checkUser(email, password) {
    const user = await User.findOne({
        where: {
          email: email,
          password: password
        }
      });
      if (user)
      {
        return (user.toJSON())
    }
    return undefined
}

export {generateAccessToken, authenticateToken, checkUser};