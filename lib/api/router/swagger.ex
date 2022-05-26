defmodule NabooAPI.Router.Swagger do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    scope("/swagger", do: forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :area, swagger_file: "swagger.json"))
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Naboo"
      }
    }
  end
end
