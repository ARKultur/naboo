import {sequelize} from './src/db/sequelize.js';
import express from 'express'
import cors from 'cors'
import * as Models from './src/db/models/index.js'
import router from './src/routes/api.js';
import { generateAdm } from './src/utils.js';
import { google } from 'googleapis';
import session from 'express-session'
import User from './src/db/models/Users.js';
import axios from 'axios';
import querystring from 'querystring'

const app = express()
const port = 4000

const CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const REDIRECT_URL = process.env.GOOGLE_REDIRECT_URL;

const OAuth2 = google.auth.OAuth2;
const oauth2Client = new OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL);

console.log(process.env.GOOGLE_CLIENT_ID)
try {
    await sequelize.authenticate();
    console.log('Connection has been established successfully.');

    for (const model of Object.values(Models)) {
	model.definition(sequelize);
    }
    
    for (const model of Object.values(Models)) {
      model.associate();
    }
    
    await sequelize.sync({ force: true });
    const adm = await generateAdm();

    console.log("admin info:", adm.toJSON());
} catch (error) {
    console.error('Unable to connect to the database:', error);
}  

app.use(session({
  secret: 'r8q,+&1LM3)CD*zAGpx1xm{NeQhc;#',
  resave: false,
  saveUninitialized: true,
  cookie: { maxAge: 60 * 60 * 1000 } // 1 hour
}));

app.use(cors());
app.use(express.json());
app.use("/api", router);

app.get('/auth/google', (req, res) => {
  const scopes = ['https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/userinfo.profile'];

  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline', // Add this line
    scope: scopes,
    prompt: 'consent', // Add this line to force the consent screen and get a refresh token on each request
  });
    console.log(authUrl)
  res.redirect(authUrl);
});

app.get('/auth/google/callback', async (req, res) => {
    const { code } = req.query;
    try {


	const postData = {
	    code: code,
	    client_id: CLIENT_ID,
	    client_secret: CLIENT_SECRET,
	    redirect_uri: REDIRECT_URL,
	    grant_type: 'authorization_code',
	};
	console.log(postData)
	try {
	await axios.post('https://oauth2.googleapis.com/token')
	    console.log("test")
	} catch (err)
	{
	    console.error(err)
	}
	const info = await axios.post('https://oauth2.googleapis.com/token', querystring.stringify(postData), {
	    headers: {
		'Content-Type': 'application/x-www-form-urlencoded',
	    },
	});
	const tokens = info.data
	console.log(tokens)
	/*
	oauth2Client.setCredentials(info.data);

    const oauth2 = google.oauth2({
      auth: oauth2Client,
      version: 'v2',
    });
	*/
	const userInfoResponse = await axios.get('https://www.googleapis.com/oauth2/v2/userinfo', {
	    headers: {
		'Authorization': `Bearer ${tokens.access_token}`,
	    },
	});

	const { data } = userInfoResponse;
	console.log(data)
    const { email, name, picture } = data;

    let user;
    try {
      user = await User.findOne({ where: { email } });
    } catch (err) {
      console.error(err);
      return res.status(500).send('Error finding user');
    }

    if (!user) {
      // If the user doesn't exist, create a new user
	try {
	    const expirationDate = new Date(Date.now() + tokens.expires_in * 1000);
        user = await User.create({
          username: name,
          email: email,
            password: "jaj",
	    accessToken: tokens.access_token,
	    refreshToken: tokens.refresh_token,
	    tokenExpiration: expirationDate
        });
      } catch (err) {
        console.error(err);
        return res.status(500).send('Error creating user');
      }
    }

    // Set the user information in the session (you can use req.session or a similar library)
	req.session.userId = user.id;

    res.redirect('/api/whoami'); // Redirect to the desired page after successful login
  } catch (err) {
    console.error(err);
    res.status(500).send(err);
  }
});



/*
app.get('/auth/google', (req, res) => {
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: ['profile', 'email'],
  });
  res.redirect(authUrl);
});

app.get('/auth/google/callback', async (req, res) => {
  const { code } = req.query;
  try {
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    const ticket = await oauth2Client.verifyIdToken({
      idToken: tokens.id_token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const { email, name, picture } = payload;

      let user;
    try {
      user = await User.findOne({ where: { email } });
    } catch (err) {
      console.error(err);
      return res.status(500).send('Error finding user');
    }

    if (!user) {
      // If the user doesn't exist, create a new user
      try {
        user = await User.create({
          username: name,
          email: email,
          password: "jaj",
        });
      } catch (err) {
        console.error(err);
        return res.status(500).send('Error creating user');
      }
    }

    // Set the user information in the session (you can use req.session or a similar library)
    req.session.userId = user.id;


    return res.redirect('/api/whoami'); // Redirect to the desired page after successful login
  } catch (err) {
    console.error(err);
    res.status(500).send('Internal Server Error');
  }
});
*/
/*
app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

app.get(
  '/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/api/login' }),
  (req, res) => {
    res.redirect('/api/whoami');
  }
);
*/
app.get('/', (req, res) => {
    res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})

export default app;
