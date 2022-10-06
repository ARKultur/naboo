# naboo

This is the ARKultur's back-end, all written in Elixir. :^)

## How to use ?

### dev

A simple `docker-compose -f docker-compose-dev.yml up --build` should be enough.
If it's not the case, please read the documentation below.

To build and run a dev version, you will need to export the data present in `.env.dev`.
I have a little function you can put in your `.bashrc` to export data to your environnemnt.
Use it as a function or it will not work:

```bash
# in your .bashrc / .zshrc / whatever
envup () {
    if [ -f ${1} ]; then
        set -o allexport
        export $(grep -v '#.*' ${1} | xargs)
        set +o allexport
    else echo "Could not find ${1}"
    fi
}

source ~/.bashrc # or .zshrc or whatever

# in the command-line
## installing dependencies (assumes you're running a debian-based distro)
./scripts/install_dev_env.sh

## exporting ENV variables
envup .env.dev

## running server
MIX_ENV=dev mix phx.server
```

Note: When installing the necessary dependencies, `install_dev_env.sh` assumes you're running a Debian-variant of Linux,
feel free to add a check to your own distro and upstream it if that's not the case.

### Run the tests

```bash
# start postgresql
sudo systemctl start postgresql.service

# init databases schemas and privileges
./scripts/setup_db.sh

# export test env variables
envup .env.test

# run the tests
make test

# or, run all of the test suite (linting, coverage, etc.)
make check
```

### Check available API routes

```bash
MIX_ENV=prod mix phx.routes
```

An OpenAPI specification is also available.

### GraphQL tests

As we use graphQL to manage our queries, you can have an interface to test
your queries.

```bash
MIX_ENV=dev mix phx.server
```

Go to `https://localhost:4000/graphql/hub`, then try a query, like so:

```graphql
{
  allAccounts {
    id
    email
    name
    isAdmin
  }
}
```

## authentication

We use [Guardian](https://github.com/ueberauth/guardian) to generate JWT tokens.
To log in, we can use the `POST /api/login` route with such `json` field:

```json
{
	"email": "sheev.palpatine@naboo.net",
	"password": "sidious"
}
```

You should receive a JWT token, like this:

```json
{
	"jwt": "some_jwt_token"
}
```

You can then just use this as a Bearer token.
