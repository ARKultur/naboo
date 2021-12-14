# Step 1 - hex dependencies
#
FROM hexpm/elixir:1.12.3-erlang-24.1.2-alpine-3.14.2 AS otp-dependencies

ARG APP_ENV
ENV MIX_ENV=${APP_ENV}

WORKDIR /build

# Install Alpine dependencies
RUN apk add --no-cache git

# Install Erlang dependencies
RUN mix local.rebar --force && \
    mix local.hex --force

# Install hex dependencies
COPY mix.* ./
RUN mix deps.get

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
RUN npm ci --prefix assets --no-audit --no-color --unsafe-perm --progress=false --loglevel=error

#
# Step 3 - build the OTP binary
#
FROM hexpm/elixir:1.12.3-erlang-24.1.2-alpine-3.14.2 AS otp-builder

ARG APP_VERSION

ENV APP_VERSION=${APP_VERSION} \
    MIX_ENV=dev

WORKDIR /build

# Install Alpine dependencies
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    make \
    erlang-dev \
    musl \
    build-base \
    inotify-tools

# Install Erlang dependencies
RUN mix local.rebar --force && \
    mix local.hex --force

# Copy hex dependencies
COPY mix.* ./
COPY --from=otp-dependencies /build/deps deps

# Copy files
COPY config config
COPY lib lib
COPY priv priv
RUN mix deps.compile

# Copy assets from step 1
COPY --from=js-builder /build/assets assets
RUN mix assets.deploy
RUN chmod a+x /build/priv/scripts/docker-entrypoint.sh

ENTRYPOINT ["/build/priv/scripts/docker-entrypoint.sh"]
