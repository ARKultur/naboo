defmodule NabooAPI.AccountControllerTest do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    email: "some email",
    password: "some password",
    password_confirmation: "some password",
    name: "some name"
  }

  @update_attrs %{
    email: "some updated email",
    password: "some updated password",
    password_confirmation: "some updated password",
    name: "some updated name"
  }

  setup %{conn: conn} do
    user = Accounts.get_account(1)
    {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some email",
               "is_admin" => false,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "update an account" do
    test "renders updated account when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.account_path(conn, :update, id), account: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Helpers.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "is_admin" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "delete an account" do
    test "delete an existing account", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.account_path(conn, :delete, id))
      assert response(conn, 200)
    end
  end

  describe "list accounts" do
    test "list available accounts", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert response(conn, 200)
    end
  end
end
