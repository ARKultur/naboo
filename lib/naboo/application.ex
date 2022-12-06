defmodule Naboo.Application do
  @moduledoc """
  Main entry point of the app
  """

  use Application

  alias Naboo.Cache

  def start(_type, _args) do
    children = [
      Naboo.Repo,
      {Phoenix.PubSub, [name: Naboo.PubSub, adapter: Phoenix.PubSub.PG2]},
      Naboo.Endpoint,
      Supervisor.child_spec({Cache, name: :totp_cache}, id: :cache_1),
      Supervisor.child_spec({Cache, name: :cf_token_cache}, id: :cache_2),
      Supervisor.child_spec({Cache, name: :pw_token_cache}, id: :cache_3)
    ]

    opts = [strategy: :one_for_one, name: Naboo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Naboo.Endpoint.config_change(changed, removed)
    :ok
  end
end
