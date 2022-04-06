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

COPY mix.* ./

# Install Erlang && hex dependencies
RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get

#
# Step 2 - npm dependencies + build the JS/CSS assets
#
FROM node:14.18-alpine3.14 AS js-builder

ARG APP_ENV
ENV NODE_ENV=${APP_ENV}

WORKDIR /build

# Install Alpine dependencies
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git

# Copy hex dependencies
COPY --from=otp-dependencies /build/deps deps

# Install npm dependencies
COPY assets assets
RUN npm i --prefix assets
RUN npm ci --prefix assets --no-audit --no-color --unsafe-perm --progress=false --loglevel=error

#
# Step 3 - build the OTP binary
#
FROM hexpm/elixir:1.13.0-erlang-24.0.3-alpine-3.14.0 AS otp-builder

ARG APP_VERSION

ENV APP_VERSION=${APP_VERSION} \
    MIX_ENV=dev

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

# Copy hex dependencies
COPY mix.* ./
COPY --from=otp-dependencies /build/deps deps

# Copy files
COPY config config
COPY lib lib
COPY priv priv

# Copy assets from step 1
COPY --from=js-builder /build/assets assets

# Install Erlang dependencies && deploy assets
RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix assets.deploy

ENTRYPOINT ["/build/priv/scripts/docker-entrypoint.sh"]
