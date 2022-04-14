import Config

version = Mix.Project.config()[:version]

config :naboo,
  ecto_repos: [Naboo.Repo],
  version: version

config :phoenix, :json_library, Jason

config :naboo, Naboo.Endpoint,
  pubsub_server: Naboo.PubSub,
  render_errors: [view: Naboo.Views.Errors, accepts: ~w(json)]

config :naboo, Naboo.Repo, start_apps_before_migration: [:ssl]

config :naboo, Corsica, allow_headers: :all

config :naboo, Naboo.Auth.Guardian,
  issuer: "naboo",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :naboo, Naboo.Auth.Sessions,
  issuer: "naboo",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :sentry,
  root_source_code_path: File.cwd!(),
  release: version

config :logger, backends: [:console, Sentry.LoggerBackend]

# Import environment configuration
import_config "#{Mix.env()}.exs"
