defmodule NabooAPI.PipelineTest do
  use Naboo.ConnCase

  alias Naboo.AccountsFixtures
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  describe "testing endpoint protection" do
    test "should not access user endpoint when disconnected", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert %{"errors" => "authentication error"} = json_response(conn, 401)
    end

    test "should not access admin endpoint when disconnected", %{conn: conn} do
      conn = get(conn, Helpers.admin_account_path(conn, :index))
      assert %{"errors" => "authentication error"} = json_response(conn, 401)
    end
  end

  describe "admin endpoint protections" do
    setup %{conn: conn} do
      account = AccountsFixtures.account_fixture()
      {:ok, jwt, conn} = Sessions.log_in(conn, account)

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt}")

      {:ok, conn: conn}
    end

    test "should not access admin endpoint as normal user", %{conn: conn} do
      conn = get(conn, Helpers.admin_account_path(conn, :index))
      assert %{"errors" => "this account is not an admin"} = json_response(conn, 401)
    end
  end
end
