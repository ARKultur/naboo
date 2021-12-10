defmodule NabooWeb.PingView do
  use Phoenix.View, root: "lib/naboo_web", path: "home/templates", namespace: NabooWeb

  def render("ping.json", _params) do
    %{
      status: 200,
      message: "pong"
    }
  end
end
