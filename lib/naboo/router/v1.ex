defmodule Naboo.Router.V1 do
  use Phoenix.Router

  pipeline :api_auth do
    plug(Naboo.Auth.Guardian.Pipeline)
  end
  scope "/v1" do
    pipe_through(:api)

  end

  scope "/v1" do
    pipe_through([:api, :api_auth])

  end
end
