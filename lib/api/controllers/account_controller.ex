defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"

  alias Naboo.Accounts
  alias Naboo.Accounts.Account

  def index(conn, _params) do
    conn
    |> put_view(NabooAPI.AccountView)
    |> render("index.json", accounts: Accounts.list_accounts())
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.register(account_params) do
      conn
      |> put_status(:created)
      |> put_view(NabooAPI.AccountView)
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    conn
    |> put_view(NabooAPI.AccountView)
    |> render("show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      conn
      |> put_view(NabooAPI.AccountView)
      |> render("show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "account deleted")
      |> halt()
    end
  end
end
