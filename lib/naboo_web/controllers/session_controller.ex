defmodule NabooWeb.SessionController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Authentication

  require Logger

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Authentication.authenticate(account, password),
         {:ok, token, conn} <- Authentication.log_in(conn, account) do
      render(conn, "token.json", token: token)
    else
      _error ->
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(403, "could not authenticate")
        |> halt()
    end
  end

  def sign_in(conn, _params) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(401, "wrong parameters")
    |> halt()
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, "disconnected.")
    |> halt()
  end
end
