import express from 'express';
import prisma from '../db/prisma.js';
import { authenticateTokenAdm } from '../utils.js';

const suggestions_router = express.Router();

suggestions_router.get('/', async (req, res) => {
  try {
    const suggestions = await prisma.suggestions.findMany();

    res.status(200).send(suggestions);
    /*c8 ignore start */
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
  /* c8 ignore stop */
});

suggestions_router.post('/', authenticateTokenAdm, async (req, res) => {
  try {
    const { name, description, imageUrl, tag } = req.body;

    if (!name || !description || !imageUrl || !tag)
      return res.status(400).send('Missing value');

    await prisma.suggestions.create({
      data: {
        name,
        description,
        imageUrl,
        tag,
      },
    });
    res.status(200).send('Suggestion successfully added');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

suggestions_router.post('/map', async (req, res) => {
  try {
    const { filters, location } = req.body;

    if (!filters || !location) return res.status(400).send('Missing value');

    const suggestions = prisma.suggestions.findMany({
      where: {
        uuid: {
          in: filters,
        },
      },
    });

    let tags = [];

    if (Array.isArray(suggestions)) {
      const tags =
        suggestions && suggestions.map((suggestion) => suggestion.tag);
    } else {
      const tags = suggestions && suggestions.tag;
    }

    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${
      location.latitude
    },${location.longitude}&radius=5000&type=${tags.join('|')}&key=${
      process.env.GOOGLE_API_KEY
    }`;

    const response = await axios.get(url, {
      headers: {
        'Content-Type': 'application/json',
      },
    });

    res.status(200).send(response);
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error', error);
  }
});

suggestions_router.delete('/:uuid', authenticateTokenAdm, async (req, res) => {
  try {
    const uuid = req.params.uuid;

    if (!uuid) return res.status(400).send('Missing arguments');

    const suggestion = await prisma.suggestions.delete({
      where: {
        uuid: uuid,
      },
    });

    if (!suggestion) return res.status(404).send('Suggestion not found');
    res.status(200).send('Suggestion successfully deleted');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

suggestions_router.post('/:uuid', authenticateTokenAdm, async (req, res) => {
  try {
    const { name, description, imageUrl, tag, uuid } = req.body;

    if (!name || !description || !imageUrl || !tag || !uuid)
      return res.status(400).send('Missing value');

    await prisma.suggestions.update({
      where: {
        uuid: uuid,
      },
      data: {
        name,
        description,
        imageUrl,
        tag,
      },
    });
    res.status(200).send('Suggestion successfully added');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

export default suggestions_router;
