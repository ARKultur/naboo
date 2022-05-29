defmodule NabooAPI.Router.Swagger do
  use Phoenix.Router

  pipeline :web do
    plug(:accepts, ["json", "html"])
  end

  scope "/swagger" do
    pipe_through(:web)

    scope("/", do: forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :naboo, swagger_file: "swagger.json"))
  end

  def swagger_info do
    %{
      info: %{
        version: "0.2",
        host: "http://localhost:4000",
        title: "naboo"
      }
    }
  end
end
