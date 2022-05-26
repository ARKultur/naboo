import Config

version = Mix.Project.config()[:version]

config :naboo,
  ecto_repos: [Naboo.Repo],
  version: version

config :phoenix, :json_library, Jason

config :naboo, Naboo.Endpoint,
  pubsub_server: Naboo.PubSub,
  render_errors: [view: NabooAPI.Views.Errors, accepts: ~w(json)]

config :naboo, Naboo.Repo, start_apps_before_migration: [:ssl]

config :naboo, Corsica, allow_headers: :all

config :naboo, NabooAPI.Auth.Guardian,
  issuer: "naboo",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :naboo, NabooAPI.Auth.Sessions,
  issuer: "naboo",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :sentry,
  root_source_code_path: File.cwd!(),
  release: version

config :logger, backends: [:console, Sentry.LoggerBackend]

config :phoenix_swagger, json_library: Jason

config :naboo, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: NabooAPI.Router.Swagger,
      endpoint: Naboo.Endpoint
    ]
  }

# Import environment configuration
import_config "#{Mix.env()}.exs"
