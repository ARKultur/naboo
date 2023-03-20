import jwt from 'jsonwebtoken';
import express from 'express'
import {User, Admin, Customer} from './db/models/index.js'

function generateAccessToken(username) {
    return jwt.sign({username}, process.env.TOKEN_SECRET, { expiresIn: "1h" });
}

function isEmpty(obj) {
    for (let i in obj)
	return false;
    return true;
}

async function generateAdm() {
  const adm = await Admin.findAll();

  if ("ADMIN_EMAIL" in process.env && "ADMIN_PASSWORD" in process.env)
  {

    if (adm.length)
    {
      return adm[0];
    } else {
      const new_adm = await Admin.create({
        email: process.env.ADMIN_EMAIL,
        password: process.env.ADMIN_PASSWORD
      })
      return new_adm;
    }
  } else {
    console.error("env variable ADMIN_EMAIL or ADMIN_PASSWORD not set!", "\nTerminating process...")
    process.exit(1)
  }
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
      try {
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
      } catch (err)
      {
	  res.sendStatus(403)
      }
  })
}

async function checkCustomer(email, password) {

    try {
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
    } catch (err)
    {
	return false;
    }
  return false
}

async function checkUser(email, password) {
    try {
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
    } catch (err)
    {
	console.log("err: ", err)
	return undefined
    }
    return undefined
}

async function checkAdmin(email, password) {
    try {
    const adm = await Admin.findOne({
    where: {
      email: email,
      password: password
    }
  });
  if (adm)
    {
      return (adm.toJSON())
    }
    } catch (err)
    {
	return undefined
    }
    return undefined
}

export {generateAccessToken, authenticateToken, checkUser, checkAdmin, authenticateTokenAdm, checkCustomer, generateAdm, isEmpty};
