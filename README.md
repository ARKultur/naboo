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

envup .env.test
ENV=dev mix phx.server
```
