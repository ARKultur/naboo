defmodule NabooAPI.SessionControllerTests do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Router.Urls.Helpers

  describe "login feature" do
    @valid_login_attrs %{
      email: "email@email.com",
      password: "some password"
    }

    @create_attrs %{
      email: "email@email.com",
      password: "some password",
      password_confirmation: "some password",
      name: "some name"
    }

    test "successfully log in", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert _response = json_response(conn, 201)
      conn = post(conn, Helpers.session_path(conn, :sign_in), @valid_login_attrs)
      assert %{"jwt" => _token} = json_response(conn, 200)
    end

    test "fail at login", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert _response = json_response(conn, 201)
      conn = post(conn, Helpers.session_path(conn, :sign_in), %{"email" => "hello", "password" => "lol"})
      assert _resp = json_response(conn, 401)
    end

    test "fail if garbage is sent at login", %{conn: conn} do
      garbage = %{
        "this" => "is",
        "some" => "garbage input",
        "something" => 231_231_231
      }

      conn = post(conn, Helpers.session_path(conn, :sign_in), garbage)
      assert _resp = json_response(conn, 401)
    end

    test "access unpermitted route should give error from middleware", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :show, 1), %{})
      assert _response = json_response(conn, 401)
    end
  end

  describe "logout feature" do
    setup %{conn: conn} do
      user = Accounts.get_account(1)
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Bearer #{jwt}")

      {:ok, conn: conn}
    end

    test "successful logout", %{conn: conn} do
      conn = post(conn, Helpers.session_path(conn, :delete))
      assert response(conn, 200)
    end
  end
end
