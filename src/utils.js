import jwt from 'jsonwebtoken';
import express from 'express'
import {User, Admin, Customer} from './db/models/index.js'

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

function authenticateTokenAdm(req, res, next) {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]


  if (token == null) return res.sendStatus(401)

  jwt.verify(token.toString(), process.env.TOKEN_SECRET, (err, user) => {

    if (err) return res.sendStatus(403)
    Admin.findOne({
      where: {
        email: user.username
      }
    }).then((res) => {
      if (res)
      {
        req.email = user.username
      } else {
        return res.sendStatus(403)
      }
      next()
    })
  })
}

async function checkCustomer(email, password) {
  const ctm = await Customer.findOne({
    where: {
      email: email,
      password: password
    }
  });
  if (ctm)
  {
    return true
  }
  return false
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

async function checkAdmin(email, password) {
  const adm = await Admin.findOne({
    where: {
      email: email,
      password: password
    }
  });
  if (adm)
  {
    return true
  }
  return false
}

export {generateAccessToken, authenticateToken, checkUser, checkAdmin, authenticateTokenAdm, checkCustomer};