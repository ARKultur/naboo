defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.AccountView
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.ChangesetView
  alias NabooAPI.Views.Errors


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
        |> put_view(ChangesetView)
        |> put_status(:forbidden)
        |> render("error.json", %{changeset: something})
    end
  end

  swagger_path(:index) do
    get("/api/account/")
    summary("Show current user from the database")
    description("Show current user")
    produces("application/json")
    deprecated(false)
    parameter(:preload_nodes, :query, :boolean, "set to true if you want to receive domains as well", required: false, default: false)

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

  def index(conn, _params) do
    id = Sessions.get_resource(conn).id
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

  swagger_path(:update) do
    patch("/api/account/")
    summary("Update current user")
    description("Update the current user's data (except password, which shall go through a different flow)")
    produces("application/json")
    deprecated(false)

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

  def update(conn, %{"account" => account_params}) do
    with %Account{} = account <- Sessions.get_resource(conn),
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

      {:error, _} ->
        conn
        |> put_view(Errors)
        |> put_status(:bad_request)
        |> render("error_messages.json", %{errors: "Could not update account"})
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/account/")
    summary("Delete current user")
    description("Delete current user account from the database")
    produces("application/json")
    deprecated(false)
    response(200, "account deleted")
  end

  def delete(conn, _params) do
    with %Account{} = account <- Sessions.get_resource(conn),
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

      {:error, _} ->
        conn
        |> put_view(Errors)
        |> put_status(:bad_request)
        |> render("error_messages.json", %{errors: "Could not delete account"})
    end
  end
end
