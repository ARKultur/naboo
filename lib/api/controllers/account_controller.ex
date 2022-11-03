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
    account = Sessions.resource(conn)
    should_preload = conn.query_params |> Access.get("preload_nodes", false)

    value =
      if should_preload do
          Accounts.get_account_preload(account.id)
      else
          Accounts.get_account(account.id)
      end

    case value do
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      %Account{} = account ->
        if should_preload && !account.is_admin do
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
    description("Update the user's data (except password, which shall go through a different flow)")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :integer, "id of the account", required: true)
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

    account = conn.assigns.current_user
    to_update =
      if account.is_admin do
        Accounts.get_account(id)
      else
        account
      end

    case Accounts.update_account(to_update, account_params) do
      {:ok, %Account{} = updated} ->
        conn
        |> put_view(AccountView)
        |> put_status(:ok)
        |> render("show.json", account: updated)

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

  def delete(conn, %{"id" => id}) do
    account = Sessions.resource(conn)

    to_delete =
      cond do
        account == nil ->
          nil
        account.is_admin ->
          Accounts.get_account(id)
        true ->
          account
      end

    with {:ok, %Account{}} <- Accounts.delete_account(to_delete) do
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
