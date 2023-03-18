FROM node:19-alpine

WORKDIR /app
COPY package.json .

RUN npm install

COPY  . .
EXPOSE 4000

CMD sh -c "if [ \"$NPM_COMMAND\" = \"start\" ]; then npm run start; elif [ \"$NPM_COMMAND\" = \"start-dev\" ]; then npm run start-dev; elif [ \"$NPM_COMMAND\" = \"test\" ]; then npm run test; fi"