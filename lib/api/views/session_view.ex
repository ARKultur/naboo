defmodule NabooAPI.SessionView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def render("token.json", %{token: token}) do
    %{
      jwt: token
    }
  end

  def render("disconnected.json", _) do
    %{
      status: 200,
      message: "successfully disconnected"
    }
  end
end
