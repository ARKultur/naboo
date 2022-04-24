defmodule Naboo.Application do
  @moduledoc """
  Main entry point of the app
  """

  use Application

  def start(_type, _args) do
    children = [
      Naboo.Repo,
      {Phoenix.PubSub, [name: Naboo.PubSub, adapter: Phoenix.PubSub.PG2]},
      Naboo.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Naboo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Naboo.Endpoint.config_change(changed, removed)
    :ok
  end
end
