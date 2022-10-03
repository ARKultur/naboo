#!/bin/env bash

envup () {
    if [ -f "${1}" ]; then
        set -o allexport
        export "$(grep -v '#.*' "${1}" | xargs)"
        set +o allexport
    else echo "Could not find ${1}"
    fi
}

install_postgresql () {
    echo "installing postgresql"

    export POSTGRES_USER="kali"
    export POSTGRES_PASSWORD="postgres"
    export POSTGRES_DB="naboo_dev"
    export POSTGRES_TEST_DB="naboo_test"

    sudo apt-get install -y postgresql postgresql-contrib libpq-dev || true
    sudo -u postgres psql -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';"
    sudo -u postgres psql -c "ALTER USER ${POSTGRES_USER} WITH SUPERUSER;"
    sudo -u postgres psql -c "GRANT postgres TO $POSTGRES_USER;"

    sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_DB};"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};"

    sudo -u postgres psql -c "CREATE DATABASE ${POSTGRES_TEST_DB};"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_TEST_DB} TO ${POSTGRES_USER};"
}


install_postgresql || exit 1
