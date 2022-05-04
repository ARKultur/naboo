#!/bin/bash

set -euo pipefail

# check if postgresql-client is installed
which pg_isready >/dev/null || { echo "Postgres is not installed. Exiting." && exit 1 ; }

#while ! pg_isready -q -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}"; do
#    echo "$(date) - waiting for database to start"
    sleep 1
#done

mix ecto.setup && exec mix phx.server
