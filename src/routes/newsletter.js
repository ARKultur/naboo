import express from 'express';
import { authenticateTokenAdm } from '../utils.js';
import nodemailer from 'nodemailer';
import prisma from '../db/prisma.js';

const newsletter_router = express.Router();

newsletter_router.get('/', authenticateTokenAdm, async (req, res) => {
  try {
    const newsletter = await prisma.newsletter.findMany();

    res.status(200).send(newsletter);
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

newsletter_router.post('/', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) return res.status(400).send('Missing value');

    await prisma.newsletter.create({
      data: {
        email,
      },
    });
    res.status(200).send('User successfully added to newsletter');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

newsletter_router.delete('/:uuid', authenticateTokenAdm, async (req, res) => {
  try {
    const uuid = req.params.uuid;
    console.log(uuid)
    if (!uuid) return res.status(400).send('Missing arguments');

    const newsletter = await prisma.newsletter.delete({
      where: {
        uuid: uuid,
      },
    });

    if (!newsletter) return res.status(404).send('User not found');
    res.status(200).send('User successfully deleted from newsletter');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

/* c8 ignore start */
const getEmailTemplate = (text) => `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Newsletter ARKULTUR</title>
</head>
<body>
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <p>${text}</p>
        <p>Nous sommes là pour vous aider ! Si vous avez des questions ou avez besoin d'assistance, n'hésitez pas à nous contacter à <a href="mailto:support@votreservice.com">support@votreservice.com</a>.</p>

        <p>Merci encore pour votre confiance.</p>
        <p>L'équipe de Votre Service</p>
        <div style="width: 100%;display: flex;justify-content: center;flex-direction:row">
        <img src="http://x2024arkultur120290831001.westeurope.cloudapp.azure.com/static/media/logo.50c21f4e749321ea7e6616c543b5e454.svg"
        width="100"/>
        </div>
        <h3 style="text-align:center">
            ARKULTUR
        </h3>
    </div>
</body>
</html>
`;

async function sendEmailToMultipleRecipients(subject, text, recipients) {
  try {
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_EMAIL,
        pass: process.env.GMAIL_PASSWORD,
      },
    });
    const info = await transporter.sendMail({
      from: process.env.GMAIL_EMAIL,
      to: recipients.join(', '),
      subject,
      html: getEmailTemplate(),
    });

    console.log('Email sent: ' + info.response);
    return info;
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
}
/* c8 ignore stop */

newsletter_router.post('/create', authenticateTokenAdm, async (req, res) => {
  try {
    const newsletter = await prisma.newsletter.findMany();
    const { subject, text } = req.body;

    if (!newsletter) return res.status(404).send('No user in newsletter');
      console.log((process.env.UT_CI == 'false'));
      if (process.env.UT_CI == 'false') {
	  const ret = await sendEmailToMultipleRecipients(subject, text, newsletter);
	  console.log(ret);
      }
    res.status(200).send('Mail successfully sent');
  } catch (error) {
    console.log(error);
    res.status(500).send('Internal Error');
  }
});

export default newsletter_router;
