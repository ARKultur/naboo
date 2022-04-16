defmodule NabooAPI.Controllers.Auth.Account do
  use Phoenix.Controller

  alias Naboo.Accounts.AccountManager
  alias Naboo.Accounts.Account

  def index(conn, _params) do
    accounts = AccountManager.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- AccountManager.register(account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = AccountManager.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = AccountManager.get_account!(id)

    with {:ok, %Account{} = account} <- AccountManager.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = AccountManager.get_account!(id)

    with {:ok, %Account{}} <- AccountManager.delete_account(account) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "account deleted")
      |> halt()
    end
  end
end
