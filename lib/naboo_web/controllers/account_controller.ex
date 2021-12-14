defmodule NabooWeb.AccountController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooWeb.Router

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.register(account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Router.Helpers.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, "show.json", account: account)
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
