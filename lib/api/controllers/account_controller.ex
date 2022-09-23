defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.AccountView
  alias NabooAPI.Views.Errors

  swagger_path(:index) do
    get("api/account")
    summary("Lists users")
    description("Lists all users in the database")
    produces("application/json")
    deprecated(false)

    response(200, "index.json", %{},
      example: %{
        accounts: [
          %{
            email: "test@test.com",
            is_admin: false,
            name: "test",
            updated_at: "2022-04-15 03:00:02.123+02:00 CEST Europe/Paris"
          },
          %{
            email: "test2@test.com",
            is_admin: false,
            name: "test2",
            updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
          }
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
    post("/api/account")
    summary("Create an user")
    description("Create an user in the database")
    produces("application/json")
    deprecated(false)

    parameter(:account_params, :body, :Account, "informations of the account",
      required: true,
      example: %{
        account: %{
          email: "test@test.com",
          password: "test_t",
          password_confirmation: "test_t",
          name: "test"
        }
      }
    )

    response(200, "show.json", %{},
      example: %{
        account: %{
          email: "test@test.com",
          is_admin: false,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
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
      {:error, something} ->
        conn
        |> put_view(Errors)
        |> put_status(403)
        |> render("error_messages.json", %{errors: something})
    end
  end

  swagger_path(:show) do
    get("/api/account/{id}")
    summary("Show an user")
    description("Show an user in the database")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "id of the user to show", required: true)

    response(200, "show.json", %{},
      example: %{
        account: %{
          email: "test@test.com",
          is_admin: false,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
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
    patch("/api/account/{id}")
    summary("Update an user")
    description("Update an user in the database")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :integer, "id of the account to update", required: true)
    parameter(:account_params, :body, :Account, "new informations of the account", required: true)

    response(200, "show.json", %{},
      example: %{
        account_params: %{
          email: "test@test.com",
          is_admin: false,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
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
    PhoenixSwagger.Path.delete("/api/account/{id}")
    summary("Delete an user")
    description("Delete an user in the database")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "id of the user to delete", required: true)
    response(200, "account deleted")
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
