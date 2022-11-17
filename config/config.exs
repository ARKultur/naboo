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

config :phoenix_swagger, json_library: Jason

config :naboo, Corsica, allow_headers: :all

config :naboo, Guardian,
  issuer: "naboo",
  secret_key: System.fetch_env!("GUARDIAN_SECRET")

config :naboo, NabooAPI.Auth.Sessions,
  issuer: "naboo",
  secret_key: System.fetch_env!("GUARDIAN_SECRET")

config :logger, backends: [:console]

config :phoenix_swagger, json_library: Jason

config :naboo, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: NabooAPI.Router.Urls,
      endpoint: Naboo.Endpoint
    ]
  }

config :naboo, Bamboo,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.fetch_env!("SENDGRID_APIKEY")

# Import environment configuration
import_config "#{Mix.env()}.exs"
