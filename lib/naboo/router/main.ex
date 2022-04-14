defmodule Naboo.Router.Main do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  scope "/api" do

  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  defp session(conn, _opts) do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: Application.get_env(:naboo, __MODULE__)[:session_key],
        signing_salt: Application.get_env(:naboo, __MODULE__)[:session_signing_salt]
      )

    Plug.Session.call(conn, opts)
  end
end
