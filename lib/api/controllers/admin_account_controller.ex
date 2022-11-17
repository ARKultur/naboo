defmodule NabooAPI.AdminAccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias Naboo.Utils.BooleanConverter
  alias NabooAPI.AccountView
  alias NabooAPI.ChangesetView

  swagger_path(:create) do
    post("/api/admin/account")
    summary("Create an admin user")
    description("Create an admin user in the database. It is almost the same as a normal user, except it can administrate other users")
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
    parameter(:only_admin, :query, :boolean, "show only admin accounts", required: false, default: false)
    parameter(:preload, :query, :boolean, "set to true if you want to receive domains as well", required: false, default: false)
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
    only_admin = conn.query_params |> Access.get("only_admin", false)
    preload = BooleanConverter.convert!(conn.query_params |> Access.get("preload", false))

    render_term =
      if preload do
        "index_preloaded.json"
      else
        "index.json"
      end

    list =
      if only_admin do
        Accounts.list_accounts(%{should_preload: preload})
        |> Enum.filter(fn x -> x.is_admin end)
      else
        Accounts.list_accounts(%{should_preload: preload})
      end

    conn
    |> put_view(AccountView)
    |> put_status(:ok)
    |> render(render_term, accounts: list)
  end
end
