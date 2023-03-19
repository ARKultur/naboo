import {expect} from 'chai'
import request from 'supertest'
import app from '../index.js'
import { isEmpty } from '../src/utils.js'

describe('test routes', function () {
    before('Mock db connection and load app', async function () {
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
    })

    describe('test organisation routes', function () {
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
		name: 'orga_test'
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
		name: 'orga_test'
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

	    const res = await patch({}, '/api/organisations', token, 500)
	    expect(res).to.equal('Internal Server Error')
	})


	it('deletes an organisation', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    req = {
		name: 'new_orga_test'
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

	it('server error on empty delete', async () => {
	    let req = {
		email: process.env.ADMIN_EMAIL,
		password: process.env.ADMIN_PASSWORD,
		username: 'jaj'
	    }
	    const token = await post(req, '/api/login');

	    const res = await del({}, '/api/organisations', token, 500)
	    expect(res).to.equal('Internal Server Error')
	})
    })
    
    //some utility functions for testing
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

