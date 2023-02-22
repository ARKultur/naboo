import {sequelize} from './src/db/sequelize.js';
import express from 'express'
import cors from 'cors'
import * as Models from './src/db/models/index.js'
import router from './src/routes/api.js';
import { generateAdm } from './src/utils.js';

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

app.use(cors());
app.use(express.json());
app.use("/api", router);

app.listen(port, () => {
  console.log(`app listening on port ${port}`)
})