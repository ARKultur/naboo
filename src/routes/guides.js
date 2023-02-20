import express from "express";

import { authenticateToken, authenticateTokenAdm} from '../utils.js';
import {Guide, User, Organisation, Node} from "../db/models/index.js"

let guide_router = express.Router()

guide_router.get("/", authenticateTokenAdm, async (req,res) => {
    const guides = await Guide.findAll()
    res.send(guides.toJSON())
})

guide_router.get("/", authenticateToken, async (req,res) => {
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
            let all_guides = [];
            for (const iterator of nodes) {
                const guides = await Guide.findAll({
                    where: {
                        NodeId: iterator.id
                    }
                });
                all_guides.push(guides);
            }
            return res.send(all_guides)
        }
    }
    res.status(401).send()
})

guide_router.get("/:id", authenticateToken, async (req, res) => {
    const guide = await Guide.findOne({
        where: {
          id: req.params.id
        }
      })
    
      if (guide)
      {
        res.send(guide.toJSON())
      } else {
        res.status(404).send("Guide not found")
      }
})

guide_router.post("/", authenticateToken, async (req, res) => {
    try {
  
        let guide = await Guide.create({
          text: req.body.text
        });
        res.send(guide.toJSON());
      } catch (err)
      {
        console.log(err);
        res.status(401).send("unexpected error");
      }
})

guide_router.patch("/", authenticateToken, async (req,res) => {
    const guide = await Guide.findOne({
        where: {
            id: req.body.id
        }
      });
      await guide.update({
          text: req.body.text || guide.text,
          NodeId: req.body.node || guide.NodeId
      })
      res.send(guide.toJSON())
})

guide_router.delete("/", authenticateToken, async (req, res) => {
    const guide = await Guide.findOne({
        where:{
          id: req.body.id
        }
      })
    
      if (guide)
      {
        guide.delete()
      } else {
        res.status(404).send("Guide not found");
      }
})

export default guide_router;