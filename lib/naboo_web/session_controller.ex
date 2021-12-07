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
    case email |> Accounts.find_by_email!() |> Authentication.authenticate(password) do
      {:ok, account} ->
        conn
        |> Authentication.log_in(account)
        |> put_session(:account_id, account.id)
        |> redirect(to: Helpers.account_path(conn, :show))

      _err ->
        Logger.info("Attempted to connect #{email} but it didn't work.")
        send_resp(conn, 404, "not found")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> put_session(:account_id, 0)
    |> redirect(to: Helpers.session_path(conn, :create))
  end
end
