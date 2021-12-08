import Config

version = Mix.Project.config()[:version]

config :naboo,
  ecto_repos: [Naboo.Repo],
  version: version

config :phoenix, :json_library, Jason

config :naboo, NabooWeb.Endpoint,
  pubsub_server: Naboo.PubSub,
  render_errors: [view: NabooWeb.Errors.View, accepts: ~w(html json)]

config :naboo, Naboo.Repo, start_apps_before_migration: [:ssl]

config :naboo, Corsica, allow_headers: :all

config :naboo, Naboo.Gettext, default_locale: "en"

config :naboo, NabooWeb.ContentSecurityPolicy, allow_unsafe_scripts: false

config :guardian, NabooWeb.Guardian,
  issuer: :naboo,
  secret_key: System.get_env("GUARDIAN_SECRET"),
  ttl: {3, :days},
  allowed_drift: 2000,
  verify_issuer: true

config :esbuild,
  version: "0.13.13",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :sentry,
  root_source_code_path: File.cwd!(),
  release: version

config :logger, backends: [:console, Sentry.LoggerBackend]

# Import environment configuration
import_config "#{Mix.env()}.exs"
