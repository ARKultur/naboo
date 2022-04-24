#!/bin/bash

set -euo pipefail

# Following regex is based on https://www.rfc-editor.org/rfc/rfc3986#appendix-B with
# additional sub-expressions to split authority into userinfo, host and port
#
readonly URI_REGEX='^(([^:/?#]+):)?(//((([^:/?#]+)@)?([^:/?#]+)(:([0-9]+))?))?(/([^?#]*))(\?([^#]*))?(#(.*))?'
#                    ↑↑            ↑  ↑↑↑            ↑         ↑ ↑            ↑ ↑        ↑  ↑        ↑ ↑
#                    |2 scheme     |  ||6 userinfo   7 host    | 9 port       | 11 rpath |  13 query | 15 fragment
#                    1 scheme:     |  |5 userinfo@             8 :…           10 path    12 ?…       14 #…
#                                  |  4 authority
#                                  3 //…

parse_scheme () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[2]}"
}

parse_authority () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[4]}"
}

parse_user () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[6]}"
}

parse_host () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[7]}"
}

parse_port () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[9]}"
}

parse_path () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[10]}"
}

parse_rpath () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[11]}"
}

parse_query () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[13]}"
}

parse_fragment () {
    [[ "$DATABASE_URL" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[15]}"
}


export POSTGRES_HOST=$(parse_host)
export POSTGRES_USER=$(parse_user)
export POSTGRES_PORT=$(parse_host)

# check if postgresql-client is installed
which pg_isready >/dev/null || { echo "Postgres is not installed. Exiting." && exit 1 ; }

while ! pg_isready -q -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" -U "${POSTGRES_USER}"; do
    echo "$(date) - waiting for database to start"
    sleep 1
done

mix ecto.setup && exec mix phx.server
