defmodule NabooAPI.SessionController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Views.Errors

  require Logger

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Sessions.authenticate(account, password),
         {:ok, token, conn} <- Sessions.log_in(conn, account) do
      render(conn, "token.json", token: token)
    end
  end

  def sign_in(conn, _params) do
    conn
    |> put_view(Errors)
    |> put_status(:unauthorized)
    |> render("401.json", [])
  end

  def delete(conn, _params) do
    conn
    |> Sessions.log_out()
    |> put_view(Accounts)
    |> put_status(:ok)
    |> render("disconnected.json", [])
  end
end
