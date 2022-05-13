defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.AccountView
  alias NabooAPI.Views.Errors

  def index(conn, _params) do
    conn
    |> put_view(AccountView)
    |> put_status(:ok)
    |> render("index.json", accounts: Accounts.list_accounts())
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.register(account_params) do
      conn
      |> put_view(AccountView)
      |> put_status(:created)
      |> render("show.json", account: account)
    else
      _ ->
        conn
        |> put_view(AccountView)
        |> put_status(403)
        |> render("already_exists.json", [])
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_account(id) do
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      account ->
        conn
        |> put_view(AccountView)
        |> put_status(:ok)
        |> render("show.json", account: account)
    end
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    with %Account{} = account <- Accounts.get_account(id),
         {:ok, %Account{} = updated} <- Accounts.update_account(account, account_params) do
      conn
      |> put_view(AccountView)
      |> put_status(:ok)
      |> render("show.json", account: updated)
    else
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      {:ko, _} ->
        conn
        |> put_view(Errors)
        |> put_status(400)
        |> render("error_messages.json", %{errors: "Could not update account"})
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Account{} = account <- Accounts.get_account(id),
         {:ok, %Account{}} <- Accounts.delete_account(account) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "account deleted")
      |> halt()
    else
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      {:ko, _} ->
        conn
        |> put_view(Errors)
        |> put_status(400)
        |> render("error_messages.json", %{errors: "Could not delete account"})
    end
  end
end
