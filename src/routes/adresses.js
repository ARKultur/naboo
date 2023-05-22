import express from "express";
import Adress from "../db/models/Adress.js";
import {authenticateTokenAdm, authenticateToken} from "../utils.js";

const adress_router = express.Router();

/**
 * @swagger
 *  components:
 *    schemas:
 *      Address:
 *        type: object
 *        required:
 *          - country
 *          - postcode
 *          - state
 *          - street_address
 *          - city
 *        properties:
 *          country:
 *            type: string
 *            description: The country where the address is located.
 *          postcode:
 *            type: number
 *            description: The postal code of the address.
 *          state:
 *            type: string
 *            description: The state where the address is located.
 *          street_address:
 *            type: string
 *            description: The street name and number of the address.
 *          city:
 *            type: string
 *            description: The city where the address is located.
 *        example:
 *           country: USA
 *           postcode: 90210
 *           state: California
 *           street_address: 123 Beverly Hills
 *           city: Los Angeles
 */

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
		street_address: street_address || addr.street_address
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
