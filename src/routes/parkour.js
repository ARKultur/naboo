import express from "express";
import prisma from '../db/prisma.js'
import { authenticateToken, authenticateTokenAdm} from '../utils.js';

const parkour_router = express.Router();

parkour_router.get("/", async (req, res) => {
    const parkours = await prisma.parkour.findMany();
    res.send(parkours);
});

parkour_router.patch("/:id", async (req, res) => {
    const id = req.params.id
    try {
        const parkour = await prisma.parkour.findFirst({
            where: {
              id: id,
            },
          });
          if (parkour) {
            const updated_parkour = await prisma.parkour.update({
              where: {
                id: parkour.id,
              },
              data: {
                name: req.body.name || customer.name,
                description: req.body.description || customer.description,
                status: req.body.status || customer.status,
                OrganisationId: req.body.organisation_id || customer.OrganisationId,
                updatedAt: Date.now()
              },
            });
            return res.json(updated_parkour);
          }
    } catch (error) {
        console.error(error)
        return res.sendStatus(500)
    }
});

parkour_router.post("/", async (req, res) => {
    try {
        const parkour = await prisma.parkour.create({
            data: {
              name: req.body.name,
              description: req.body.description,
              status: req.body.status,
            },
          });
          res.json(parkour);
    } catch (error) {
        console.error(error)
        return res.sendStatus(500)
    }
});

parkour_router.delete("/:id", async (req, res) => {
    const id = req.params.id
    try {
        const parkour = await prisma.parkour.delete({
            where: {
                id: id
            }
        })
        res.json(parkour)
    } catch (error) {
        console.error(error)
        return res.sendStatus(500)
    }
});

export default parkour_router;