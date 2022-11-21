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

config :logger, backends: [:console]

config :phoenix_swagger, json_library: Jason

config :naboo, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: NabooAPI.Router.Urls,
      endpoint: Naboo.Endpoint
    ]
  }

# Import environment configuration
import_config "#{Mix.env()}.exs"
