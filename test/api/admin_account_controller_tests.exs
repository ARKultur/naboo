defmodule NabooAPI.AdminAccountControllerTest do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias Naboo.AccountsFixtures
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    "email" => "email@email.com",
    "password" => "some password",
    "password_confirmation" => "some password",
    "name" => "some name"
  }

  setup %{conn: conn} do
    account = Accounts.get_account!(1)
    {:ok, jwt, conn} = Sessions.log_in(conn, account)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.admin_account_path(conn, :create), account: @create_attrs)

      assert %{
               "id" => id,
               "message" => "account created, please confirm your account by email"
             } = json_response(conn, 201)

      conn = get(conn, Helpers.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "email@email.com",
               "is_admin" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "fail when account is duplicated", %{conn: conn} do
      conn = post(conn, Helpers.admin_account_path(conn, :create), account: @create_attrs)

      assert %{
               "id" => _id,
               "message" => "account created, please confirm your account by email"
             } = json_response(conn, 201)

      conn = post(conn, Helpers.admin_account_path(conn, :create), account: @create_attrs)
      assert %{"errors" => [%{"detail" => "has already been taken", "field" => "name"}]} = json_response(conn, 403)
    end

    test "fail when account data is completely invalid", %{conn: conn} do
      attrs = %{
        hello: "world",
        testvalue: 1234,
        gaming: true
      }

      conn = post(conn, Helpers.admin_account_path(conn, :create), account: attrs)

      assert %{
               "errors" => [
                 %{"detail" => "can't be blank", "field" => "password"},
                 %{"detail" => "can't be blank", "field" => "email"},
                 %{"detail" => "can't be blank", "field" => "name"}
               ]
             } = json_response(conn, 403)
    end

    test "fail if account email is invalid", %{conn: conn} do
      args = %{
        "email" => "some wrong email",
        "name" => "some valid name",
        "password" => "very cool password"
      }

      conn = post(conn, Helpers.admin_account_path(conn, :create), account: args)

      assert %{
               "errors" => [%{"detail" => "has invalid format", "field" => "email"}]
             } = json_response(conn, 403)
    end
  end

  test "return a list of accounts", %{conn: conn} do
    _simple_acc1 = AccountsFixtures.account_fixture()
    _simple_acc2 = AccountsFixtures.account_fixture()
    _simple_acc3 = AccountsFixtures.account_fixture()
    _simple_acc4 = AccountsFixtures.account_fixture()

    _simple_adm1 = AccountsFixtures.admin_fixture()
    _simple_adm2 = AccountsFixtures.admin_fixture()
    _simple_adm3 = AccountsFixtures.admin_fixture()
    _simple_adm4 = AccountsFixtures.admin_fixture()

    conn = get(conn, Helpers.admin_account_path(conn, :index))
    assert json_response(conn, 200)

    conn = get(conn, Helpers.admin_account_path(conn, :index), %{preload: true, only_admin: true})
    assert json_response(conn, 200)
  end
end
