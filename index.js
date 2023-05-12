import {sequelize} from './src/db/sequelize.js';
import express from 'express'
import cors from 'cors'
import * as Models from './src/db/models/index.js'
import router from './src/routes/api.js';
import { generateAdm } from './src/utils.js';
import passport from 'passport'
import './src/passport.js';
import session from 'express-session'
const app = express()
const port = 4000

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
app.use(passport.initialize());
app.use(passport.session());
app.use("/api", router);
app.set('trust proxy', true);

app.get('/auth/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

app.get(
  '/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/api/login' }),
  (req, res) => {
    res.redirect('/api/whoami');
  }
);

app.get('/', (req, res) => {
    res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})

export default app;
