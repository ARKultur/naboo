defmodule NabooWeb.SessionController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Authentication
  alias NabooWeb.Router.Helpers

  require Logger

  def new(conn, _params) do
    if Authentication.get_current_account(conn) do
      redirect(conn, to: Helpers.account_path(conn, :show))
    else
      redirect(conn, to: Helpers.session_path(conn, :create))
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Authentication.authenticate(account, password),
         {:ok, token, conn} <- Authentication.log_in(conn, account) do
      render(conn, "token.json", token: token)
    else
      _error -> send_resp(conn, 401, "could not authenticate")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> redirect(to: Helpers.session_path(conn, :create))
  end
end
