import express from "express";

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
import {Node, User, Organisation} from '../db/models/index.js'

let node_router = express.Router()

node_router.get('/', authenticateTokenAdm, async (req, res) => {
    const nodes = await Node.findAll();
    res.send(nodes.toJSON())
})
node_router.get('/', authenticateToken, async (req, res) => {
    const user = User.findOne({
        where: {
            email: req.email
        }
    })
    if (user)
    {
        console.log(user.OrganisationId)
        const orga = await Organisation.findByPk(user.OrganisationId)
        if (orga)
        {
            console.log(orga)
            res.send(orga.toJSON())
            const nodes = await Node.findAll({
                where: {
                    OrganisationId: orga.id
                }
            });
            return res.send(nodes.toJSON())
        }
    }
    res.status(401).send()
})

node_router.get('/:name', authenticateToken, async (req, res) => {
    const node = await Node.findOne({
        where: {
            name: req.body.name
        }
    });
    if (node)
    {
        return res.send(node.toJSON())
    } else {
        return res.status(404).send("node not found")
    }
})

node_router.post('/', authenticateToken, async (req, res) => {
    
    try {
        const node = await Node.create({
            name: req.body.name,
            longitude: req.body.longitude,
            latitude: req.body.latitude
        });
        return res.send(node.toJSON())
    } catch (error) {
        console.log(err);
        res.status(401).send("node already existing");
    }
})

node_router.patch('/', authenticateToken, async (req, res) => {
    const node = await Node.findOne({
        where: {
            name: req.body.name
        }
    });

    if (node)
    {
        node.update({
            latitude: req.body.latitude || node.latitude,
            longitude: req.body.longitude || node.longitude,
            addressId: req.body.address || node.addressId,
            OrganisationId:req.body.organisation || node.OrganisationId 
        });
        res.send(node.toJSON())
    }
})

node_router.delete('/', authenticateToken, async (req, res) => {
    const node = await Node.findOne({
        where:{
          name: req.body.name
        }
      })
    
      if (node)
      {
        node.delete()
      } else {
        res.status(404).send("Node not found");
      }
})

export default node_router;