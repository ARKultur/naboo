#!/bin/env bash

install_postgresql () {
    echo "installing postgresql"

     export POSTGRES_USER="${USER}"
	 export POSTGRES_PASSWORD="postgres"
	 export POSTGRES_DB="naboo"
     export POSTGRES_TEST_DB="${POSTGRES_DB}_test"

	 sudo apt-get install -y postgresql postgresql-contrib libpq-dev || true
	 sudo -u postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD $POSTGRES_PASSWORD';"
	 sudo -u postgres psql -c "GRANT postgres TO $POSTGRES_USER;"
	 sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_DB;"
	 sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"
	 sudo -u postgres psql -c "CREATE DATABASE $POSTGRES_TEST_DB;"
	 sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_TEST_DB TO $POSTGRES_USER;"
}

install_postgresql && mix ecto.create
