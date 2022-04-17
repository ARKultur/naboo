defmodule NabooAPI.Router.Urls do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  pipeline :api_auth do
    plug(Naboo.Auth.Guardian.Pipeline)
  end

  scope "/api" do
    pipe_through(:api)

    scope "/v1" do
      post("/login", NabooAPI.Controllers.Auth.Session, :sign_in)
      resources("/account", NabooAPI.Controllers.Auth.Account, only: [:create])

      pipe_through(:api_auth)
      resources("/account", NabooAPI.Controllers.Auth.Account, only: [:update, :delete, :show, :index])
    end
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  defp session(conn, _opts) do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: Application.fetch_env!(:naboo, __MODULE__)[:session_key],
        signing_salt: Application.fetch_env!(:naboo, __MODULE__)[:session_signing_salt]
      )

    Plug.Session.call(conn, opts)
  end
end
