import express from "express";
import { authenticateTokenAdm } from "../utils.js";

import prisma from "../db/prisma.js";

const suggestions_router = express.Router();

suggestions_router.get("/", async (req, res) => {
  try {
    const suggestions = await prisma.suggestions.findMany();

    res.status(200).send(suggestions);
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

suggestions_router.get("/:uuid", async (req, res) => {
  try {
    const uuid = req.params.uuid;
    const suggestion = await prisma.suggestions.findUnique({
      where: {
        uuid: uuid,
      },
    });

    res.status(200).send(suggestion);
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

suggestions_router.post("/", authenticateTokenAdm, async (req, res) => {
  try {
    const { title, description, image } = req.body;

    if (!(title && description)) return res.status(400).send("Missing value");

    await prisma.suggestions.create({
      data: {
        title: title,
        description: description,
        image: image,
      },
    });
    res.status(200).send("Suggestion successfully created");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

suggestions_router.patch("/:uuid", authenticateTokenAdm, async (req, res) => {
  try {
    const uuid = req.params.uuid;
    const { title, description, image } = req.body;

    if (!(title && description)) return res.status(400).send("Missing value");

    const suggestion = await prisma.suggestion.findUnique({
      where: {
        uuid: uuid,
      },
    });

    if (!suggestion) return res.status(404).send("Suggestion not found");

    await prisma.suggestion.update({
      where: {
        uuid: uuid,
      },
      data: {
        title: title,
        description: description,
        image: image,
      },
    });

    res.status(200).send("Suggestion successfully updated");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

suggestions_router.delete("/:uuid", authenticateTokenAdm, async (req, res) => {
  try {
    const uuid = req.params.uuid;

    if (!uuid) return res.status(400).send("Missing arguments");

    const suggestion = await prisma.suggestions.delete({
      where: {
        uuid: uuid,
      },
    });

    if (!suggestion) return res.status(404).send("Suggestion not found");
    res.status(200).send("Suggestion successfully deleted");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

export default suggestions_router;
