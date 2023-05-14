FROM debian:stable-slim

WORKDIR /app
COPY package.json .

RUN apt update
RUN apt install -y dnsutils
RUN apt -y install curl software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - 
RUN apt -y install nodejs

RUN npm install

COPY  . .
EXPOSE 4000

CMD sh -c "if [ \"$NPM_COMMAND\" = \"start\" ]; then npm run start; elif [ \"$NPM_COMMAND\" = \"start-dev\" ]; then npm run start-dev; elif [ \"$NPM_COMMAND\" = \"test\" ]; then npm run test; fi"
