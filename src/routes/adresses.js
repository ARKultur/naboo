import express from "express";
import Adress from "../db/models/Adress.js";
import {authenticateTokenAdm, authenticateToken} from "../utils.js";

const adress_router = express.Router();

adress_router.get('/admin', authenticateTokenAdm, async (req, res) => {
    const addresses = await Adress.findAll();
    res.send(addresses);
})

adress_router.get('/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
	const adr = await Adress.findOne({ where: { id: id}})
	
	if (adr)
	{
	    res.send(adr)
	} else
	{
	    res.status(404).json({error: 'Address not found'})
	}
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
})

adress_router.post('/', authenticateToken, async (req, res) => {
    try {
	const { country, postcode, state, city, street_address} = req.body;
	const addr = await Adress.create({
	    country: country,
	    postcode: postcode,
	    state: state,
	    city: city,
	    street_address: street_address
	});

	res.json({id: addr.id})
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
});

adress_router.patch('/', authenticateToken, async (req, res) => {
    try {
	const {id, country, postcode, state, city, street_address, CustomerId, NodeId, OrganisationId, UserId} = req.body
	const addr = await Adress.findOne({
	    where: {
		id: id
	    }
	});

	if (addr)
	{
	    await addr.update({
		country: country || addr.country,
		postcode: postcode || addr.postcode,
		state: state || addr.state,
		city: city || addr.city,
		street_address: street_address || addr.street_address,
		CustomerId: CustomerId || addr.CustomerId,
		NodeId: NodeId || addr.NodeId,
		OrganisationId: OrganisationId || addr.OrganisationId,
		UserId: UserId || addr.UserId
	    });
	    res.send(addr)
	} else
	{
	    res.status(404).send("Address not found")
	}
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
});

adress_router.delete('/', authenticateToken, async (req, res) => {
    try {
	const addr = await Adress.findOne({
	    where: {
		id: req.body.id
	    }
	})

	if (addr)
	{
	    await addr.destroy();
	    res.send("Address successfully deleted")
	} else
	{
	    res.status(404).send("Address not found")
	}
    } catch (err)
    {
	console.error(err)
	res.sendStatus(500)
    }
});

export default adress_router;
