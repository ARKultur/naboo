#!/bin/bash

source .env

if [ "$NPM_COMMAND" == "test" ]; then
    docker-compose up --build -d db
    sleep 5
    npm run test
    docker-compose down
    exit 0
else
    docker-compose up --build -d db
    sleep 5
    npm run start
fi
