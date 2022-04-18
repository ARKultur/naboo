defmodule NabooAPI.Views.Session do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def render("token.json", %{token: token}) do
    %{
      jwt: token
    }
  end
end
