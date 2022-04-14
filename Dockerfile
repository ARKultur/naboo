# Step 1 - hex dependencies
#
FROM hexpm/elixir:1.13.0-erlang-24.0.3-alpine-3.14.0 AS otp-dependencies

ARG APP_ENV
ENV MIX_ENV=${APP_ENV}

WORKDIR /build

# Install Alpine dependencies
RUN apk add --no-cache git \
    make \
    build-base

COPY mix.exs ./

# Install Erlang && hex dependencies
RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get && \
    mix deps.compile

#
# Step 2 - build the OTP binary
#
FROM hexpm/elixir:1.13.0-erlang-24.0.3-alpine-3.14.0 AS otp-builder

ARG APP_VERSION
ARG APP_ENV

ENV APP_VERSION=${APP_VERSION}
ENV MIX_ENV=${APP_ENV}

WORKDIR /build

# Install Alpine dependencies
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    erlang-dev \
    make \
    build-base \
    inotify-tools

RUN mix local.rebar --force && \
    mix local.hex --force

# Copy hex dependencies (step 1)
COPY --from=otp-dependencies /build/deps deps
COPY --from=otp-dependencies /build/_build _build
COPY --from=otp-dependencies /build/mix.exs .
COPY --from=otp-dependencies /build/mix.lock .

# Copy files from filesystem
COPY config config
COPY lib lib
COPY priv priv

# Copying files for test and CI
COPY coveralls.json coveralls.json
COPY .credo.exs .credo.exs
COPY .sobelow-conf .
COPY .formatter.exs .

RUN mix assets.deploy
ENTRYPOINT ["/build/priv/docker-entrypoint.sh"]
