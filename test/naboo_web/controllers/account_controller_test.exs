defmodule NabooWeb.AccountControllerTest do
  use NabooWeb.ConnCase

  alias Naboo.Accounts
  alias NabooWeb.Guardian
  alias NabooWeb.Router.Helpers

  @create_attrs %{
    email: "some email",
    password: "some password",
    password_confirmation: "some password",
    name: "some name"
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
end
