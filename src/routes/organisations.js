import express from "express";
import User from "../db/models/Users.js"
import Organisation from "../db/models/Organisations.js";
import { authenticateToken} from '../utils.js';
 
const orga_router = express.Router();

orga_router.get('/', authenticateToken, (req, res) => {
    res.status(404).send();
})

orga_router.post('/', authenticateToken, async (req, res) => {
  
    try {
      const orga = await Organisation.create({
        name: req.body.name
      })
      res.send(orga);  
    } catch (error) {
      res.status(401).send("name already taken");
    }
})
  
orga_router.patch('/', authenticateToken, async (req, res) => {
    const orga = await Organisation.findOne({
      where: {
        name: req.body.name
      }
    });
    if (orga)
    {
      orga.update({
        name: req.body.name || orga.name,
      })
      
      res.send(orga);
    } else {
      res.status(404).send("Organisation not found");
    }
})
  
orga_router.delete('/', authenticateToken, async (req, res) => {
    const orga = await Organisation.findOne({
      where: {
        name: req.body.name
      }
    })
  
    if (orga)
    {
      orga.destroy()
    } else {
      res.status(404).send("Organisation not found");
    }
})

export default orga_router;