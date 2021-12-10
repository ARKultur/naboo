defmodule NabooWeb.SessionController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Authentication

  require Logger

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Authentication.authenticate(account, password),
         {:ok, token, conn} <- Authentication.log_in(conn, account) do
      # TODO save token to user so that it can be checked in middleware

      render(conn, "token.json", token: token)
    else
      _error -> send_resp(conn, 403, "could not authenticate")
    end
  end

  def sign_in(conn, _params) do
    send_resp(conn, 401, "wrong parameters")
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> send_resp(200, "disconnected.")
  end
end
