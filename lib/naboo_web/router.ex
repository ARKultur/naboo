defmodule NabooWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])

    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)

    plug(:protect_from_forgery)
    plug(NabooWeb.ContentSecurityPolicy)
  end

  scope "/" do
    pipe_through(:api)

    get("/status", NabooWeb.AuthController, :index)
    post("/login", NabooWeb.AuthController, :new)
    post("/logout", NabooWeb.AuthController, :delete)
    post("/register", NabooWeb.AuthController, :create)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: NabooWeb.Schema,
      interface: :simple,
      context: %{pubsub: NabooWeb.Endpoint}
    )
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
