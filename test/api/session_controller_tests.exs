defmodule NabooAPI.SessionControllerTests do
  use Naboo.ConnCase

  alias NabooAPI.Router.Urls.Helpers

  describe "sessions" do
    @valid_login_attrs %{
      email: "some cool email",
      password: "some password"
    }

    @create_attrs %{
      email: "some cool email",
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

    test "access unpermitted route should give error from middleware", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :show, 1), %{})
      assert _response = json_response(conn, 401)
    end
  end
end
