import {sequelize} from './src/db/sequelize.js';
import express from 'express'
import cors from 'cors'
import {User, Organisation, Node, Adress} from './src/db/models/index.js'
import { generateAccessToken, authenticateToken, checkUser } from "./src/utils.js";

const app = express()
const port = 4000

try {
    await sequelize.authenticate();
    console.log('Connection has been established successfully.');

    User.definition(sequelize)
    Organisation.definition(sequelize)
    Adress.definition(sequelize)
    Node.definition(sequelize)
    
    User.associate(sequelize)
    Node.associate(sequelize)
    Organisation.associate(sequelize)

    await sequelize.sync({ force: true });
} catch (error) {
    console.error('Unable to connect to the database:', error);
}  

app.use(cors());
app.use(express.json());

app.get('/api/account', authenticateToken, async (req, res) => {
  const users = await User.findAll({
  });
  res.send(users)
})

app.get('/api/account/:username', authenticateToken, async (req, res) => {
  const user = await User.findOne({
    where: {
      username: req.params.username
    }
  })

  if (user)
  {
    res.send(user.toJSON())
  } else {
    res.status(404).send("User not found")
  }
})

app.delete('/api/account/:username', authenticateToken, async (req, res) => {
  const user = await User.findOne({
    where:{
      username: req.params.username
    }
  })

  if (user)
  {
    user.delete()
  } else {
    res.status(404).send("User not found");
  }
})

app.patch('/api/account', authenticateToken, async (req, res) => {
  const user = await User.findAll({
    where: {
      email: req.email
    }
  })[0];
  user.update({
    username: req.body.username || user.username,
    password: req.body.password || user.password
  })
  res.send(user)
})

app.post('/api/login', async (req, res) => {

  try {
    const user = await checkUser(req.body.email, req.body.password)
    if (user)
    {
      const token = generateAccessToken(req.body.email);
    
      res.json(token);
    } else
    {
      res.status(401).send("invalid credentials");  
    }
  } catch (error) {
    res.status(401).send("invalid credentials");  
  }
})

app.post('/api/signin', async (req, res) => {
  try {

    let user = await User.create({
      username: req.body.username,
      password: req.body.password,
      email: req.body.email
    });
    res.send(user);
  } catch (err)
  {
    console.log(err);
    res.status(401).send("email or username already taken");
  }
})

app.post('/api/logout', authenticateToken, (req, res, next) => {
  res.send("work in progress");
})

app.post('/api/organisations', authenticateToken, async (req, res) => {
  
  try {
    const orga = await Organisation.create({
      name: req.body.name
    })
    res.send(orga);  
  } catch (error) {
    res.status(401).send("name already taken");
  }
})

app.patch('/api/organisations', authenticateToken, async (req, res) => {
  const orga = await Organisation.findOne({
    where: {
      name: req.body.name
    }
  });
  if (orga)
  {
    orga.update({
      name: req.body.name || orga.name,
    })
    
    res.send(orga);
  } else {
    res.status(404).send("Organisation not found");
  }
})

app.delete('/api/organisations', authenticateToken, async (req, res) => {
  const orga = await Organisation.findOne({
    where: {
      name: req.body.name
    }
  })

  if (orga)
  {
    orga.destroy()
  } else {
    res.status(404).send("Organisation not found");
  }
})

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})