FROM node:19-alpine
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app

COPY package.json .

USER node

RUN npm install

COPY --chown=node:node . .

EXPOSE 4000

CMD sh -c "if [ \"$NPM_COMMAND\" = \"start\" ]; then npm run start; elif [ \"$NPM_COMMAND\" = \"start-dev\" ]; then npm run start-dev; elif [ \"$NPM_COMMAND\" = \"test\" ]; then npm run test; fi"