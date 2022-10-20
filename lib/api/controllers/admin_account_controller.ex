defmodule NabooAPI.AdminAccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.AccountView
  alias NabooAPI.ChangesetView
  alias NabooAPI.Views.Errors

  swagger_path(:create) do
    post("/api/admin/account")
    summary("Create an admin user")
    description(
      "Create an admin user in the database. It is almost the same as a normal user, except it can administrate other users")
    produces("application/json")
    deprecated(false)

    parameter(:account_params, :body, :Account, "informations of the account",
      required: true,
      example: %{
        account: %{
          email: "test@test.com",
          password: "test_t",
          name: "test"
        }
      }
    )

    response(200, "show.json", %{},
      example: %{
        account: %{
          email: "test@test.com",
          is_admin: true,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
      }
    )
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.register_admin(account_params) do
      conn
      |> put_view(AccountView)
      |> put_status(:created)
      |> render("show.json", account: account)
    else
      {:error, something} ->
        conn
        |> put_view(ChangesetView)
        |> put_status(403)
        |> render("error.json", %{changeset: something})
    end
  end

  swagger_path(:index) do
    get("api/admin/account")
    summary("Lists all users (account & admins)")
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
            is_admin: true,
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

  swagger_path(:show) do
    get("/api/account/{id}")
    summary("Show an user")
    description("Show an user in the database")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "id of the user to show", required: true)
    parameter(:preload_nodes, :query, :boolean, "set to true if you want to receive domains as well", required: false, default: false)

    response(200, "show.json", %{},
      example: %{
        account: %{
          email: "test@test.com",
          is_admin: true,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
      }
    )
  end

  def show(conn, %{"id" => id}) do
    should_preload = conn.query_params |> Access.get("preload_nodes", false)

    value =
      if should_preload do
        Accounts.get_account_preload(id)
      else
        Accounts.get_account(id)
      end

    case value do
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      %Account{} = account ->
        if should_preload and not account.is_admin do
          conn
          |> put_view(AccountView)
          |> put_status(:ok)
          |> render("show_preload.json", account: account)
        else
          conn
          |> put_view(AccountView)
          |> put_status(:ok)
          |> render("show.json", account: account)
        end
    end
  end
end
