defmodule NabooWeb.SessionView do
  use Phoenix.View, root: "lib/naboo_web", path: "home/templates", namespace: NabooWeb

  def render("token.json", %{token: token}) do
    %{
      jwt: token
    }
  end
end
