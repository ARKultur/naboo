defmodule NabooWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(NabooWeb.Guardian.AuthPipeline)
  end

  # this might be useful if we want a hello-world page for the
  # back, or some documentation about the routes server by
  # the back-end
  pipeline :browser do
    plug(:accepts, ["html", "json"])

    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)

    plug(:protect_from_forgery)
    plug(NabooWeb.ContentSecurityPolicy)

    plug(:put_layout, {NabooWeb.Layouts.View, :naboo})
  end

  scope "/api" do
    pipe_through(:api)

    post("/login", NabooWeb.SessionController, :sign_in)
    resources("/account", NabooWeb.AccountController, only: [:create])
  end

  scope "/api" do
    pipe_through([:api, :api_auth])

    get("/protected-ping", NabooWeb.PingController, :index)
    resources("/account", NabooWeb.AccountController, only: [:update, :delete, :show, :index])
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
