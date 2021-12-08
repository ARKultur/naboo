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
      render(conn, :new,
        changeset: Accounts.change_account(),
        action: Helpers.session_path(conn, :create)
      )
    end
  end

  def create(conn, %{"account" => %{"email" => email, "password" => password}}) do
    with {:ok, account} <- Accounts.find_by_email!(email),
         {:ok, _} <- Authentication.authenticate(email, password),
         {:ok, token, conn} <- Authentication.log_in(conn, account) do
      conn
      |> put_session(:account_id, account.id)
      |> render("token.json", token: token)
    else
      _error -> send_resp(conn, 401, "could not authenticate")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> put_session(:account_id, 0)
    |> redirect(to: Helpers.session_path(conn, :create))
  end
end
