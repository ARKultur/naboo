defmodule NabooAPI.Router.Swagger do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  def swagger_info do
    %{
      basePath: "/api",
      info: %{
        version: "0.1",
        host: "http://localhost:8080",
        title: "Naboo's API"
      }
    }
  end
end
