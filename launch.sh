#!/bin/bash

source .env

if ["$NPM_COMMAND" == "test"]; then
    docker-compose up --build -d db --exit-code-from app
    sleep 5
    docker-compose up --build app
else
    docker-compose up --build -d db
    sleep 5
    docker-compose up --build app
fi
