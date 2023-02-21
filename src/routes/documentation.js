import express from "express";
import swaggerJsdoc from "swagger-jsdoc";
import swaggerUiExpress from "swagger-ui-express";

const doc_router = express.Router();

const options = {
    definition: {
        openapi: "3.0.0",
        info: {
          title: "ARKultur backend API with Swagger",
          version: "0.1.0",
          description:
            "This is a CRUD API made with Express and documented with Swagger",
          license: {
            name: "MIT",
            url: "https://spdx.org/licenses/MIT.html",
          }
        },
        servers: [
          {
            url: "http://localhost:4000",
          },
        ],
      },
      apis: ["./src/routes/*.js"],
};

const specs = swaggerJsdoc(options);

doc_router.use('/', swaggerUiExpress.serve, swaggerUiExpress.setup(specs, { explorer: true}));
export default doc_router;