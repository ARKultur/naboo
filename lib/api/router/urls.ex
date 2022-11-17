defmodule NabooAPI.Router.Urls do
  use Phoenix.Router

  pipeline :api do
    plug(:accepts, ["json", "html"])
    plug(:session)
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  pipeline :api_auth do
    plug(NabooAPI.Auth.Guardian.Pipeline)
  end

  pipeline :api_admin do
    plug(NabooAPI.Auth.Guardian.IsAdminPipeline)
  end

  scope "/api" do
    pipe_through(:api)
    post("/login", NabooAPI.SessionController, :sign_in)
    resources("/account", NabooAPI.AccountController, only: [:create])
    forward("/swagger", PhoenixSwagger.Plug.SwaggerUI, otp_app: :naboo, swagger_file: "swagger.json")
  end

  scope "/api" do
    pipe_through([:api, :api_auth])
    post("/logout", NabooAPI.SessionController, :delete)
    resources("/account", NabooAPI.AccountController, only: [:update, :delete, :show, :index])
    resources("/node", NabooAPI.NodeController)
    resources("/address", NabooAPI.AddressController)
  end

  scope "/api/admin" do
    pipe_through([:api, :api_auth, :api_admin])

    resources("/account", NabooAPI.AdminAccountController, only: [:create, :index])
    resources("/account", NabooAPI.AccountController, only: [:update, :delete, :show])
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

  def swagger_info do
    %{
      info: %{
        version: "0.4.0",
        host: System.get_env("CANONICAL_URL"),
        title: "naboo"
      }
    }
  end
end
