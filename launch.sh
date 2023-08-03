#!/bin/bash

source .env

if [ "$NPM_COMMAND" == "test" ]; then
    docker-compose up --build -d db
    sleep 5
    docker-compose up --build app
    EXIT_CODE=$(docker wait naboo_app_1)
    docker-compose down
    exit "$EXIT_CODE"
else
    docker-compose up --build -d db
    sleep 5
    docker-compose up --build app
fi
