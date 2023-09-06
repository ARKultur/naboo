import jwt from 'jsonwebtoken';
import express from 'express'
//import {User, Admin, Customer} from './db/models/index.js'
import axios from 'axios'

import prisma from './db/prisma.js'

function generateAccessToken(username) {
    return jwt.sign({username}, process.env.TOKEN_SECRET, { expiresIn: "1h" });
}

function isEmpty(obj) {
    for (let i in obj)
	return false;
    return true;
}

async function checkTable(tableName) {
  try {
      const result = await prisma.$executeRaw`SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '${tableName}')`;

      if (!result)
	  return false
      return true;
  } catch (error) {
    console.error(error);
    return false;
  }
}


async function generateAdm() {

    //const adm = await Admin.findAll();
    try {
	if ("ADMIN_EMAIL" in process.env && "ADMIN_PASSWORD" in process.env)
	{
	    if (!await checkTable("admin"))
	    {
		const new_adm = await prisma.admin.create({
		    data: {
			email: process.env.ADMIN_EMAIL,
			password: process.env.ADMIN_PASSWORD
		    }
		})

		return new_adm;
	    }
	    const adm = await prisma.admin.findMany();
	    if (adm.length)
	    {
		return adm[0];
	    } else {
		/*
		  const new_adm = await Admin.create({
		  email: process.env.ADMIN_EMAIL,
		  password: process.env.ADMIN_PASSWORD
		  })*/
		const new_adm = await prisma.admin.create({
		    data: {
			email: process.env.ADMIN_EMAIL,
			password: process.env.ADMIN_PASSWORD
		    }
		})

		return new_adm;
	    }
	} else {
	    console.error("env variable ADMIN_EMAIL or ADMIN_PASSWORD not set!", "\nTerminating process...")
	    process.exit(1)
	}
    } catch (err)
    {
	console.error(err)
	process.exit(1)
    }
}

async function authenticateTokenCustomer(req, res, next) {
    if (req.session && req.session.userId)
    {
	try {
	    //const user = await User.findByPk(req.session.userId);
	    const user = await prisma.customers.findUnique({ where: { id: req.session.userId } });
	    if (!user) {
		return res.sendStatus(401);
	    }
	    req.email = user.email;
	    return next();
	} catch (err) {
	    console.error(err);
	    return res.sendStatus(401);
	}
    } else {

	const authHeader = req.headers['authorization']
	const token = authHeader && authHeader.split(' ')[1]

	
	if (token == null) return res.sendStatus(401)
	
	jwt.verify(token.toString(), process.env.TOKEN_SECRET, (err, user) => {
	    
	    if (err) return res.sendStatus(403)
	    req.email = user.username
	    
	    next()
	})
    }
}

async function authenticateToken(req, res, next) {
    if (req.session && req.session.userId)
    {
	try {
	    //const user = await User.findByPk(req.session.userId);
	    const user = await prisma.user.findUnique({ where: { id: req.session.userId } });
	    if (!user) {
		return res.sendStatus(401);
	    }
	    req.email = user.email;
	    return next();
	} catch (err) {
	    console.error(err);
	    return res.sendStatus(401);
	}
    } else {

	const authHeader = req.headers['authorization']
	const token = authHeader && authHeader.split(' ')[1]

	
	if (token == null) return res.sendStatus(401)
	
	jwt.verify(token.toString(), process.env.TOKEN_SECRET, (err, user) => {
	    
	    if (err) return res.sendStatus(403)
	    req.email = user.username
	    
	    next()
	})
    }
}


function authenticateTokenAdm(req, res, next) {
    const authHeader = req.headers['authorization']
    const token = authHeader && authHeader.split(' ')[1]


    if (token == null) return res.sendStatus(401)

    jwt.verify(token.toString(), process.env.TOKEN_SECRET, async (err, user) => {

	if (err) return res.sendStatus(403)
	try {
	    /*
	      Admin.findOne({
	      where: {
              email: user.username
	      }
	      }).then((adm) => {
	      if (adm)
	      {
              req.email = user.username
	      } else {
              return res.sendStatus(403)
	      }
	    */
	    const adm = await prisma.admin.findFirst({ where: { email: user.username } });
	    
	    if (!adm)
		return res.sendStatus(403)
	    req.email = user.username
	    next()
	} catch (err)
	{
	    res.sendStatus(403)
	}
    })
}

async function checkCustomer(email, password) {

    try {
	const ctm = await prisma.customers.findFirst({ where: { email: email, password: password } });
	/*
	const ctm = await Customer.findOne({
    where: {
      email: email,
      password: password
    }
    });
    */
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
	/*
    const user = await User.findOne({
        where: {
          email: email,
          password: password
        }
	});
	*/
	const user = await prisma.user.findFirst({ where: { email: email, password: password } });
      if (user)
    {
        return (user)
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
	/*
    const adm = await Admin.findOne({
    where: {
      email: email,
      password: password
    }
    });
	*/
	const adm = await prisma.admin.findFirst({ where: { email: email, password: password } });
  if (adm)
    {
      return (adm)
    }
    } catch (err)
    {
	return undefined
    }
    return undefined
}

export {generateAccessToken, authenticateToken, checkUser, checkAdmin, authenticateTokenAdm, checkCustomer, generateAdm, isEmpty, authenticateTokenCustomer};
