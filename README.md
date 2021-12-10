# naboo

This is the ARKultur's back-end, all written in Elixir. :^)

## How to use ?

### dev

To build and run a dev version, you will need to export the data present in `.env.dev`.
I have a little function you can put in your `.bashrc` to export data to your environnemnt.
Use it as a function or it will not work:

```bash
# in your .bashrc
envup () {
    if [ -f ${1} ]; then
        set -o allexport
        export $(grep -v '#.*' ${1} | xargs)
        set +o allexport
    else echo "Could not find ${1}"
    fi
}


# in the command-line
## installing dependencies
./scripts/install_dev_env.sh

## exporting ENV variables
envup .env.test

## running server
ENV=dev mix phx.server
```

### Check available API routes

```bash
MIX_ENV=prod mix phx.routes
```

### Test your queries

As we use graphQL to manage our queries, you can have an interface to test
your queries.

```bash
MIX_ENV=dev mix phx.server
```

Go to `https://localhost:4001/graphql/hub`, then try a query, like so:

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

Then, you can test if you're correclty authenticated using the `GET /api/protected-ping`
route, setting in your Request Hearder the following key:
`Authorization: Bearer some_jwt_token`.
The API should then respond `pong!`


