import express from "express";
import prisma from "../db/prisma.js";
import { authenticateTokenAdm } from "../utils.js";

const suggestions_router = express.Router();

suggestions_router.get("/", async (req, res) => {
  try {
    const suggestions = await prisma.suggestions.findMany();

    res.status(200).send(suggestions);
    /*c8 ignore start */
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
  /* c8 ignore stop */
});

suggestions_router.post("/", authenticateTokenAdm, async (req, res) => {
  try {
    const { name, description, imageUrl } = req.body;

    if (!name || !description || !imageUrl)
      return res.status(400).send("Missing value");

    await prisma.suggestions.create({
      data: {
        name,
        description,
        imageUrl,
      },
    });
    res.status(200).send("Suggestion successfully added");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

export default suggestions_router;
