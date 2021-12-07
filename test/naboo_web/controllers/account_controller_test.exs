defmodule NabooWeb.AccountControllerTest do
  use NabooWeb.ConnCase

  import Naboo.AccountsFixtures
  alias NabooWeb.Router.Helpers

  alias Naboo.Accounts.Account

  @palpatine %{"email" => "sheev.palpatine@naboo.net", "encrypted_password" => nil, "id" => 1, "is_admin" => true, "name" => "darth sidious"}

  @create_attrs %{
    email: "some email",
    password: "some password",
    password_confirmation: "some password",
    name: "some name"
  }
  @update_attrs %{
    email: "some updated email",
    password: "some updated password",
    is_admin: false,
    name: "some updated name"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert json_response(conn, 200)["data"] == [@palpatine]
    end
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

  describe "update account" do
    setup [:create_account]

    test "renders account when data is valid", %{conn: conn, account: %Account{id: id} = account} do
      conn = put(conn, Helpers.account_path(conn, :update, account), account: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Helpers.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "is_admin" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "delete account" do
    setup [:create_account]

    test "deletes chosen account", %{conn: conn, account: account} do
      conn = delete(conn, Helpers.account_path(conn, :delete, account))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, Helpers.account_path(conn, :show, account))
      end)
    end
  end

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end
end
