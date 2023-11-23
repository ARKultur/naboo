import express from "express";
import account_router from "./account.js";
import orga_router from "./organisations.js";
import utils_router from "./utils.js";
import node_router from "./nodes.js";
import guide_router from "./guides.js";
import customer_router from "./customers.js";
import contact_router from "./contact.js";
import doc_router from "./documentation.js";
import orb_router from "./orb.js";
import adress_router from "./adresses.js";
import newsletter_router from "./newsletter.js";
import suggestions_router from "./suggestions.js";
import review_router from "./review.js";
import parkour_router from "./parkour.js"

let router = express.Router();

router
  .get("/", function (req, res) {
    res.status(404).send();
  })
  .use("/accounts", account_router);

router.use("/review", review_router);
router.use("/guides", guide_router);
router.use("/parkour", parkour_router)
router.use("/nodes", node_router);
router.use("/organisations", orga_router);
router.use("/", utils_router);
router.use("/customers", customer_router);
router.use("/documentation", doc_router);
router.use("/contact", contact_router);
router.use("/orb", orb_router);
router.use("/address", adress_router);
router.use("/newsletter", newsletter_router);
router.use("/suggestion", suggestions_router);

export default router;
