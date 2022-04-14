#!/bin/sh
set -e

mix ecto.setup
exec mix phx.server
