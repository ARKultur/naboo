import Config

defmodule TestEnvironment do
  @database_name_suffix "_test"

  def get_database_url do
    url = System.fetch_env!("DATABASE_URL")

    if is_nil(url) || String.ends_with?(url, @database_name_suffix) do
      url
    else
      raise "Expected database URL to end with '#{@database_name_suffix}', got: #{url}"
    end
  end
end

config :naboo, Naboo.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: TestEnvironment.get_database_url()

config :naboo, Naboo.Endpoint, server: false

config :logger, level: :warn
