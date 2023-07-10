import {expect} from 'chai'
import request from 'supertest'
import app from '../index.js'
import { isEmpty } from '../src/utils.js'
import prisma from '../src/db/prisma.js'

describe('test routes', function () {
    before('Mock db connection and load app', async function () {
	await prisma.user.deleteMany();
	await prisma.customers.deleteMany();
	await prisma.organisations.deleteMany();
	await prisma.nodes.deleteMany();
	await prisma.guide.deleteMany();
	await prisma.orb.deleteMany();
	await prisma.contact.deleteMany();
	await prisma.adresses.deleteMany();
    })

    describe('test utility routes', function () {
	const url_register = '/api/signin'
	const url_login = '/api/login'

	it('create a new user', async function () {
	    const req = {
		username: 'test',
		password: 'fish',
		email: 'test@test.com'
	    }
	    const res = await post(req, url_register)
	    expect(res.email).to.be.a('string');
	})
	it('fails to create a new user', async function() {
	    const req = {
		username: 'test'
	    };
	    const res = await post(req, url_register, '',401)
	    expect(res.email).to.be.undefined
	})

	it('logs in as a regular user', async () => {
	    const req = {
		email: 'test@test.com',
		password: 'fish',
		username: 'test'
	    }
	    const res = await post(req, url_login);
	    expect(res).to.be.a('string')
	})

	it('logs in as an administrator', async () => {
	    const req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const res = await post(req, url_login);
	    expect(res).to.be.a('string')
	})

	it('fails to log in', async () => {
	    const res = await post({}, url_login, '', 401)
	    expect(res).to.equal("invalid credentials")
	})

	it('check who it is', async() => {
	    const req = {
		email: 'test@test.com',
		password: 'fish',
		username: 'test'
	    }
	    const tok = await post(req, url_login)
	    const res = await get('/api/whoami', tok);
	    expect(res.identity).to.equal('test@test.com')
	})
	
	it('logs out', async () => {
	    const req = {
		email: 'test@test.com',
		password: 'fish',
		username: 'test'
	    }
	    const tok = await post(req, url_login)
	    const res = await post({}, '/api/logout', tok)
	    expect(res).to.be.a('string')
	})

	it('verify user email', async () => {
	    const req = {
		email: 'test@test.com',
		password: 'fish',
		username: 'test'
	    }
	    const tok = await post(req, url_login)

	    let res = await get('/api/accounts/verification', tok)
	    expect(res.token).to.be.a('string')

	    const confirm_token = res.token
	    res = await get(`/api/accounts/confirm?token=${confirm_token}`, tok)
	    expect(res.text).to.equal('Your email has been confirmed.')
	})

	it('reset a user password', async () => {
	    let req = {
		email: 'test@test.com',
		password: 'fish',
		username: 'test'
	    }
	    const tok = await post(req, url_login)

	    let res = await get('/api/accounts/forgot', tok)
	    expect(res.token).to.be.a('string')

	    const confirm_token = res.token

	    const new_req = {
		token: confirm_token,
		password: req.password,
		new_password: 'fishh'
	    }
	    res = await post(new_req, `/api/accounts/reset`, tok)
	    expect(res).to.equal('Password succesfully resetted')
	})
    })

    describe('test organisation routes', function () {
	let org_id = 0;
	
	it('gets all the organisations', async () => {
	    const req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await get('/api/organisations', token)
	    expect(res).to.be.empty
	})

	it('creates a new organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		name: 'orga_test'
	    }
	    const res = await post(req, '/api/organisations', token)
	    expect(res.name).to.equal('orga_test')
	    org_id = res.id;
	})

	it('fails to create a new organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await post({}, '/api/organisations', token, 401)
	    expect(res.name).to.not.equal('orga_test')
	})

	it('patches an organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		new_name: 'new_orga_test',
		id: org_id
	    }

	    const res = await patch(req, '/api/organisations', token)
	    expect(res.name).to.equal('new_orga_test')
	})

	it('fails to patch an organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		name: 'orga_test',
		id: 787878787
	    }

	    const res = await patch(req, '/api/organisations', token, 404)
	    expect(res).to.equal("Organisation not found")
	})

	it('patch with no arguments', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await patch({}, '/api/organisations', token, 404)
	    expect(res).to.equal('Organisation not found')
	})


	it('deletes an organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		id: org_id
	    }
	    const res = await del(req, '/api/organisations', token)
	    expect(res).to.equal('success')
	})

	it('fails to delete an organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		name: 'new_orga_test'
	    }
	    const res = await del(req, '/api/organisations', token, 404)
	    expect(res).to.equal("Organisation not found")
	})
    })

    describe('Test nodes routes', function() {
	before('setup an organisation with a user', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token_adm = await post(req, '/api/login');

	    req = {
		name: 'orga_test'
	    }
	    const orga = await post(req, '/api/organisations', token_adm)

	    req = {
		username: 'test',
		password: 'fishh',
		email: 'test@test.com'
	    }
	    const token_user = await post(req, '/api/login')


	    const user = await get(`/api/accounts?email=${req.email}`, token_user)
	    req = {
		OrganisationId: orga.id,
		id: user.id
	    }
	    const res = await patch(req, '/api/accounts/admin', token_adm)
	})
	
	it('get all the nodes', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await get('/api/nodes/all', token)
	    expect(res).to.be.empty
	})

	it('get the nodes of an organisation', async () => {
	    let req = {
		username: 'test',
		password: 'fishh',
		email: 'test@test.com'
	    }
	    const token_user = await post(req, '/api/login')

	    const res = await get('/api/nodes', token_user)
	    expect(res).to.be.empty
	})

	it('create a node', async () => {
	    let req = {
		username: 'test',
		password: 'fishh',
		email: 'test@test.com'
	    }
	    const token_user = await post(req, '/api/login')

	    req = {
		name: 'test_node',
		longitude: 102,
		latitude: 103,
		description: 'cool'
	    }
	    const res = await post(req, '/api/nodes', token_user)
	    expect(res.name).to.equal('test_node')
	})

	it('fails to create a node', async () => {
	   let req = {
		username: 'test',
		password: 'fishh',
		email: 'test@test.com'
	    }
	    const token_user = await post(req, '/api/login')

	    const res = await post({}, '/api/nodes', token_user, 500)
	    expect(res).to.equal('Internal Server Error')
	})

	it('test search by name', async () => {
	    const token_user = await log_user()

	    const res = await get('/api/nodes/test_node', token_user)
	    expect(res.name).to.equal('test_node')
	})

	it('patch a node', async () => {
	    let req = {
		username: 'test',
		password: 'fishh',
		email: 'test@test.com'
	    }
	    const token_user = await post(req, '/api/login')

	    req = {
		name: 'test_node',
		longitude: 12,
		latitude: 1
	    }
	    const res = await patch(req, '/api/nodes', token_user)
	    expect(res.name).to.equal('test_node')
	})
    })

    describe('Test addresses routes', function() {
	let adr_id = 0;
	it('fetch all addresses', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await get('/api/address/admin', token)
	    expect(res).to.be.empty
	})

	it('creates an address', async () => {
	    const token_user = await log_user();

	    let req = {
		country: "France",
		postcode: 100,
		state: "ss",
		city: "Os",
		street_address: "26"
	    }
	    const res = await post(req, '/api/address', token_user);
	    adr_id = res.id;
	    expect(res.id).to.not.equal(0)
	})

	it('fails to create an address', async () => {
	    const token_user = await log_user();

	    let req = {
		postcode: "lol"
	    }

	    const res = await post(req, '/api/address', token_user, 500);
	})

	it('fetches a specific address', async () => {
	    const token_user = await log_user();

	    const res = await get(`/api/address/${adr_id}`, token_user);
	    expect(res.id).to.equal(adr_id)
	})

	it('fails to fetch a specific address', async () => {
	    const token_user = await log_user();

	    const res = await get('/api/address/1000', token_user, 404);
	    await get('/api/address/test', token_user, 500);
	    expect(res.error).to.equal('Address not found')
	})

	it('patches a specific address', async () => {
	    const token_user = await log_user();

	    let req = {
		country: "J",
		postcode: 12,
		state: "ee",
		city: "Raaaaa",
		street_address: "eeeee",
		id: adr_id
	    }

	    const res = await patch(req, '/api/address/', token_user);
	    expect(res.postcode).to.equal(12)
	})

	it('deletes an address', async () => {
	    const token_user = await log_user();

	    let req = {
		id: adr_id
	    }

	    const res = await del(req, '/api/address/', token_user)
	    expect(res).to.equal("Address successfully deleted");
	})

	it('fails to delete an address', async () => {
	    const token_user = await log_user()

	    let req = {
		id: "hey"
	    }

	    const res = await del(req, '/api/address/', token_user, 500)
	})
    })

    describe('Test guides routes', function() {
	let token_user;
	let guide_id;
	
	it('fetch all the guides', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await get('/api/guides/admin', token)
	    expect(res).to.be.empty
	})
	
	it('creates a guide', async () => {
	    token_user = await log_user();

	    const req = {
		text: "something"
	    }

	    const res = await post(req, '/api/guides', token_user);
	    guide_id = res.id;
	    expect(res.text).to.equal('something')
	})

	it('fetch the guides of an organisation', async () => {
	    const res = await get('/api/guides', token_user);
	    expect(res.length).to.equal(1)
	})

	it('fetch a guide', async () => {
	    const res = await get(`/api/guides/${guide_id}`, token_user);
	    expect(res.text).to.equal('something')
	})

	it('fails to fetch a guide', async () => {
	    const res = await get('/api/guides/-12', token_user, 404);
	    expect(res.error).to.equal("Guide not found")
	})
    })
    async function log_user(user = 'test', pass = 'fishh', email = 'test@test.com') {
	let req = {
		username: user,
		password: pass,
		email: email
	    }
	const token_user = await post(req, '/api/login')
	return token_user
    }
    
    //async utility functions for testing
    async function post(req, url, token = '', status = 200) {
	const {body, text} = await request(app).post(url).set({
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json',
    }).send(req).expect(status)
	if (isEmpty(body))
	{
	    return text
	} else
	{
	    return body
	}
    }

    async function get(url, token = '', status = 200) {
	const {body, text} = await request(app).get(url).set({
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json',
	}).send().expect(status)
	return body;
    }

    async function patch(req, url, token = '', status = 200) {
	const {body, text} = await request(app).patch(url).set({
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json',
    }).send(req).expect(status)
	if (isEmpty(body))
	{
	    return text
	} else
	{
	    return body
	}
    }

    async function del(req, url, token = '', status = 200) {
	const {body, text} = await request(app).delete(url).set({
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json',
    }).send(req).expect(status)
	if (isEmpty(body))
	{
	    return text
	} else
	{
	    return body
	}
    }
})

