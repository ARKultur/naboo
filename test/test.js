import {expect} from 'chai'
import request from 'supertest'
import app from '../index.js'
import { isEmpty } from '../src/utils.js'

describe('test routes', function () {
    before('Mock db connection and load app', async function () {
    })

    describe('test basic register and login', function () {
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
	    //expect(res).to.be.a('string')
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
})

