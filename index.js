import {sequelize} from './src/db/sequelize.js';
import express from 'express'
import cors from 'cors'
import * as Models from './src/db/models/index.js'
import router from './src/routes/api.js';
import { generateAdm } from './src/utils.js';
import { google } from 'googleapis';
import session from 'express-session'
import User from './src/db/models/Users.js';
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

    const oauth2 = google.oauth2({
      auth: oauth2Client,
      version: 'v2',
    });

    const { data } = await oauth2.userinfo.get();
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

    res.redirect('/'); // Redirect to the desired page after successful login
  } catch (err) {
    console.error(err);
    res.status(500).send('Internal Server Error');
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
