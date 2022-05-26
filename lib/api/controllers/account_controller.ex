defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.AccountView
  alias NabooAPI.Views.Errors

  swagger_path(:index) do
    get("/account")
    summary("Lists users")
    description("Lists all users in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(:AccountView),
      example: %{
        data: [
        %{
          _params: ""
          },
        ]
      }
    )
  end

  def index(conn, _params) do
    conn
    |> put_view(AccountView)
    |> put_status(:ok)
    |> render("index.json", accounts: Accounts.list_accounts())
  end


  swagger_path(:create) do
    get("/account")
    summary("Create an user")
    description("Create an user in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          account_params: "jaj"
          },
        ]
      }
    )
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

  swagger_path(:show) do
    get("/account")
    summary("Show an user")
    description("Show an user in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          id: 12
          },
        ]
      }
    )
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

  swagger_path(:update) do
    get("/account")
    summary("Update an user")
    description("Update an user in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          id: 12,
          account: "jaj"
          },
        ]
      }
    )
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

  swagger_path(:delete) do
    get("/account")
    summary("Delete an users")
    description("Delete an user in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          id: 12
          },
        ]
      }
    )
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
