#!/bin/bash

set -euo pipefail

# check if postgresql-client is installed
which pg_isready >/dev/null || { echo "Postgres is not installed. Exiting." && exit 1 ; }

# wait for postgresql service to boot
while ! pg_isready -q -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}"; do
    echo "$(date) - waiting for ${POSTGRES_HOST} to start on port ${POSTGRES_PORT} with user ${POSTGRES_USER}"
    sleep 1
done

if [ "${MIX_ENV}" == "prod" ]; then
    # Run the migration first using the custom release task and
    # launch the OTP release and replace the caller as Process #1 in the container
    /opt/palpatine/bin/naboo eval "Naboo.ReleaseTasks.migrate" && \
        exec /opt/palpatine/bin/naboo "$@"
else
    mix deps.get && \
        mix deps.compile && \
        mix ecto.setup && \
        exec mix phx.server
fi
