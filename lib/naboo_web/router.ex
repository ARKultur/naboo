defmodule NabooWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
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

    plug(:put_layout, {NabooWeb.Layouts.View, :app})
  end

  scope "/" do
    pipe_through([:api])

    get("/register", NabooWeb.RegistrationController, :new)
    post("/register", NabooWeb.AccountController, :create)

    get("/login", NabooWeb.SessionController, :new)
    post("/login", NabooWeb.SessionController, :create)

    get("/logout", NabooWeb.SessionController, :delete)
    post("/logout", NabooWeb.SessionController, :delete)

    resources("/account", NabooWeb.AccountController)
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
