defmodule NabooWeb.AccountControllerTest do
  use NabooWeb.ConnCase

  import Naboo.AccountsFixtures
  alias NabooWeb.Router.Helpers

  alias Naboo.Accounts.Account

  @create_attrs %{
    email: "some email",
    encrypted_password: "some encrypted_password",
    is_admin: true,
    name: "some name"
  }
  @update_attrs %{
    email: "some updated email",
    encrypted_password: "some updated encrypted_password",
    is_admin: false,
    name: "some updated name"
  }
  @invalid_attrs %{email: nil, encrypted_password: nil, is_admin: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
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
               "encrypted_password" => "some encrypted_password",
               "is_admin" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
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
               "encrypted_password" => "some updated encrypted_password",
               "is_admin" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, account: account} do
      conn = put(conn, Helpers.account_path(conn, :update, account), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
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
