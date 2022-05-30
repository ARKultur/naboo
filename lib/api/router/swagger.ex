defmodule NabooAPI.Router.Swagger do
  use Phoenix.Router

  pipeline :web do
    plug(:accepts, ["json", "html"])
  end

  scope "/swagger" do
    pipe_through(:web)

    forward("/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :naboo, swagger_file: "swagger.json")
  end
end
