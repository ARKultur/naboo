defmodule NabooAPI.SessionView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def render("token.json", %{token: token}) do
    %{
      jwt: token
    }
  end

  def render("2fa.json", %{}) do
    %{
      message: "logged in, a two-factor code has been sent"
    }
  end

  def render("disconnected.json", _) do
    %{
      status: 200,
      message: "successfully disconnected"
    }
  end
end
