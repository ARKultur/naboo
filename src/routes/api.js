import express from "express";
import account_router from "./account.js"
import orga_router from "./organisations.js"
import utils_router from "./utils.js"
import node_router from "./nodes.js";
import guide_router from "./guides.js";
import customer_router from "./customers.js";

import { generateAccessToken, authenticateToken, checkUser } from '../utils.js';

let router = express.Router();

router.get("/", function(req, res) {
    res.status(404).send();
}).use("/account", account_router);

router.use("/guides", guide_router);
router.use("/nodes", node_router);
router.use("/organisations", orga_router);
router.use('/', utils_router);
router.use('/customers', customer_router)


export default router;