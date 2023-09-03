import express from "express";
import { authenticateTokenAdm } from "../utils.js";
import nodemailer from "nodemailer";
import prisma from "../db/prisma.js";

const newsletter_router = express.Router();

newsletter_router.get("/", authenticateTokenAdm, async (req, res) => {
  try {
    const newsletter = await prisma.newsletter.findMany();

    res.status(200).send(newsletter);
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

newsletter_router.post("/", async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) return res.status(400).send("Missing value");

    await prisma.newsletter.create({
      data: {
        email,
      },
    });
    res.status(200).send("User successfully added to newsletter");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

newsletter_router.delete("/:uuid", authenticateTokenAdm, async (req, res) => {
  try {
    const uuid = req.params.uuid;

    if (!uuid) return res.status(400).send("Missing arguments");

    const newsletter = await prisma.newsletter.delete({
      where: {
        uuid: uuid,
      },
    });

    if (!newsletter) return res.status(404).send("User not found");
    res.status(200).send("User successfully deleted from newsletter");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_EMAIL,
    pass: process.env.GMAIL_PASSWORD,
  },
});

export async function sendEmailToMultipleRecipients(subject, text, recipients) {
  try {
    const info = await transporter.sendMail({
      from: process.env.GMAIL_EMAIL,
      to: recipients.join(", "),
      subject,
      text,
    });

    console.log("Email sent: " + info.response);
    return info;
  } catch (error) {
    console.error("Error sending email:", error);
    throw error;
  }
}

newsletter_router.post("/create", authenticateTokenAdm, async (req, res) => {
  try {
    const newsletter = await prisma.newsletter.findMany();
    const { subject, text } = req.body;

    if (!newsletter) return res.status(404).send("No user in newsletter");

    sendEmailToMultipleRecipients(subject, text, newsletter);
    res.status(200).send("Mail successfully sent");
  } catch (error) {
    console.log(error);
    res.status(500).send("Internal Error");
  }
});

export default newsletter_router;
