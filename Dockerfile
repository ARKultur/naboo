# Step 1 - hex dependencies
#
FROM hexpm/elixir:1.14.0-erlang-23.3.4.14-alpine-3.14.5 as otp-dependencies

ENV MIX_ENV=prod

WORKDIR /build

# Install Alpine dependencies
RUN apk add --no-cache git \
    make \
    build-base

COPY mix.exs ./
COPY config config
COPY lib lib
COPY priv priv

# Install Erlang && hex dependencies
RUN mix local.rebar --force && \
    mix local.hex --force && \
    mix deps.get --only prod && \
    mix deps.compile

#
# Step 2 - build the OTP binary
#
FROM hexpm/elixir:1.14.0-erlang-23.3.4.14-alpine-3.14.5 as otp-builder

ARG APP_VERSION
ENV MIX_ENV=prod

WORKDIR /build

# Install Alpine dependencies
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    erlang-dev \
    make \
    bash \
    postgresql-client \
    build-base \
    inotify-tools

RUN mix local.rebar --force && \
    mix local.hex --force

# Copy hex dependencies (step 1)
COPY --from=otp-dependencies /build/deps deps
COPY --from=otp-dependencies /build/config config
COPY --from=otp-dependencies /build/lib lib
COPY --from=otp-dependencies /build/priv priv
COPY --from=otp-dependencies /build/_build _build
COPY --from=otp-dependencies /build/mix.exs .
COPY --from=otp-dependencies /build/mix.lock .

# Generating release files
RUN mix assets.deploy && \
    mix compile && \
    mix phx.gen.release && \
    mix release

#
# Step 3 - Copy binary to final container
#
FROM alpine:3.15.0 AS final

ARG APP_VERSION

ENV MIX_ENV=prod
WORKDIR /opt/palpatine

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache \
        postgresql-client \
        bash \
        openssl \
        libgcc \
        libstdc++ \
        ncurses-libs

# Copy the OTP binary from the build step
COPY --from=otp-builder /build/_build/prod/naboo-${APP_VERSION}.tar.gz .
RUN tar -xvzf naboo-${APP_VERSION}.tar.gz && \
    rm naboo-${APP_VERSION}.tar.gz


# Copy Docker entrypoint
COPY priv/docker-entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

# Create non-root user
RUN adduser -D palpatine && \
    chown -R palpatine: /opt/palpatine
USER palpatine

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["start"]
