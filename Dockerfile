FROM debian:stable-slim

WORKDIR /app
COPY package.json .

RUN apt update
RUN apt-get -y install curl software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo bash - 
RUN apt install nodejs npm -y

RUN npm install

COPY  . .
EXPOSE 4000

CMD sh -c "if [ \"$NPM_COMMAND\" = \"start\" ]; then npm run start; elif [ \"$NPM_COMMAND\" = \"start-dev\" ]; then npm run start-dev; elif [ \"$NPM_COMMAND\" = \"test\" ]; then npm run test; fi"
