defmodule NabooAPI.AccountController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias Naboo.Cache
  alias Naboo.Utils.BooleanConverter
  alias NabooAPI.AccountView
  alias NabooAPI.Auth.{Sessions, TwoFactor}
  alias NabooAPI.ChangesetView
  alias NabooAPI.Email
  alias NabooAPI.Views.Errors

  swagger_path(:create) do
    post("/api/account")
    summary("Create an user")
    description("Create an user in the database")
    produces("application/json")
    deprecated(false)

    parameter(:account_params, :body, :Account, "informations for the account",
      required: true,
      example: %{
        account: %{
          email: "test@test.com",
          password: "test_t",
          name: "test"
        }
      }
    )

    response(201, "created.json", %{},
      example: %{
        message: "account created, please confirm your account by email",
        id: 1
      }
    )
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.register(account_params),
         confirm_token = TwoFactor.gen_token() do
      # ttl: 16 minutes
      Cache.put(:cf_token_cache, confirm_token, account.id, 1_000_000)

      {:ok, _value} =
        Email.welcome_email(account.name, account.email, confirm_token)
        |> Email.send()

      conn
      |> put_view(AccountView)
      |> put_status(:created)
      |> render("created.json", account: account)
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
    summary("Show list of users from the database")
    description("Show current user")
    produces("application/json")
    deprecated(false)
    parameter(:preload, :query, :boolean, "set to true if you want to receive domains as well", required: false, default: false)

    response(200, "show.json", %{},
      example: %{
        account: %{
          email: "test@test.com",
          is_admin: false,
          name: "test",
          has_2fa: false,
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
      }
    )
  end

  def index(conn, _params) do
    account = Sessions.resource(conn)
    should_preload = BooleanConverter.convert!(conn.query_params |> Access.get("preload", false))

    render_term =
      if should_preload do
        "index_preloaded.json"
      else
        "index.json"
      end

    list =
      cond do
        account.is_admin ->
          Accounts.list_accounts(%{should_preload: should_preload})

        not account.is_admin and should_preload ->
          [Accounts.get_account_preload(account.id)]

        true ->
          [account]
      end

    conn
    |> put_view(AccountView)
    |> put_status(:ok)
    |> render(render_term, accounts: list)
  end

  swagger_path(:show) do
    get("/api/account/{id}")
    summary("Shows a user's details")
    description("Shows a user's account details")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :integer, "id of the account", required: true)
    parameter(:preload, :query_params, :boolean, "should preload nodes & access data", required: false, default: false)

    response(200, "show.json", %{},
      example: %{
        account_params: %{
          email: "test@test.com",
          is_admin: false,
          has_2fa: false,
          name: "test",
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
      }
    )
  end

  def show(conn, %{"id" => id}) do
    current_user = Sessions.resource(conn)
    should_preload = BooleanConverter.convert!(conn.query_params |> Access.get("preload_nodes", false))

    view_name =
      if should_preload do
        "show_preload.json"
      else
        "show.json"
      end

    to_display =
      if should_preload do
        Accounts.get_account_preload(id)
      else
        Accounts.get_account(id)
      end

    cond do
      current_user.id != id and not current_user.is_admin ->
        conn
        |> put_view(Errors)
        |> put_status(:unauthorized)
        |> render("error_messages.json", %{errors: "you are not authorized to view this account"})

      to_display == nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("error_messages.json", %{errors: "account not found"})

      true ->
        conn
        |> put_view(AccountView)
        |> put_status(:ok)
        |> render(view_name, %{account: to_display})
    end
  end

  swagger_path(:update) do
    patch("/api/account/{id}")
    summary("Update an user")
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
          has_2fa: false,
          updated_at: "2022-06-31 12:00:00+02:00 CEST Europe/Paris"
        }
      }
    )
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Sessions.resource(conn)
    to_update = Accounts.get_account(id)

    cond do
      not account.is_admin and account.id != id ->
        conn
        |> put_view(Errors)
        |> put_status(:unauthorized)
        |> render("error_messages.json", %{errors: "you are not authorized to view this account"})

      to_update == nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("error_messages.json", %{errors: "account not found"})

      true ->
        case Accounts.update_account(to_update, account_params) do
          {:ok, %Account{} = updated} ->
            conn
            |> put_view(AccountView)
            |> put_status(:ok)
            |> render("show.json", account: updated)

          {:error, changeset} ->
            conn
            |> put_view(Errors)
            |> put_status(:bad_request)
            |> render("error_messages.json", %{errors: changeset.errors})
        end
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/account/{id}")
    summary("Delete an user")
    description("Delete an user account from the database")
    produces("application/json")
    deprecated(false)
    response(200, "account deleted")
  end

  def delete(conn, %{"id" => id}) do
    account = Sessions.resource(conn)
    to_delete = Accounts.get_account(id)

    cond do
      not account.is_admin and account.id != id ->
        conn
        |> put_view(Errors)
        |> put_status(:unauthorized)
        |> render("error_messages.json", %{errors: "you are not authorized to view this account"})

      to_delete == nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("error_messages.json", %{errors: "account not found"})

      true ->
        if nil != Accounts.delete_account(to_delete) do
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, "account deleted")
          |> halt()
        else
          conn
          |> put_view(Errors)
          |> put_status(:bad_request)
          |> render("error_messages.json", %{errors: "Could not delete account"})
        end
    end
  end
end
