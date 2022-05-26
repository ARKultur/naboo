defmodule NabooAPI.Router.Urls do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  pipeline :api_auth do
    plug(NabooAPI.Auth.Guardian.Pipeline)
  end

  scope "/api" do
    pipe_through(:api)

    scope("/swagger", do: forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :naboo, swagger_file: "swagger.json"))

    post("/login", NabooAPI.SessionController, :sign_in)
    resources("/account", NabooAPI.AccountController, only: [:create])

    pipe_through(:api_auth)
    post("/logout", NabooAPI.SessionController, :delete)
    resources("/account", NabooAPI.AccountController, only: [:update, :delete, :show, :index])
  end

  def swagger_info do
    %{
      basePath: "/api",
      info: %{
        version: "0.2",
        host: "http://localhost:4000",
        title: "naboo"
      }
    }
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
