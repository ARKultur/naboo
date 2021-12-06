defmodule NabooWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias Naboo.Repo
  alias NabooWeb.Endpoint
  alias Phoenix.ConnTest

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest

      import NabooWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    {:ok, conn: %{ConnTest.build_conn() | host: host()}}
  end

  defp host, do: Application.get_env(:naboo, :canonical_host)
end
