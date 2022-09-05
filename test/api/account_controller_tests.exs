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

  @create_account_query """
    mutation CreateSimpleAccount($e:String!, $n:String!, $p:String!, $i:String!) {
      createAccount(email: $e, name: $n, password:$p, isAdmin:$i) {
        email,
        id,
        name
      }
    }
  """

  @delete_account_query """
    mutation DeleteSimpleAccount($id: ID!) {
     deleteAccount(id: $id) {
      id
     }
    }
  """

  @get_account_query """
  query findAccount($id: ID!) {
    getAccount(id: $id) {
      name
      email
    }
  }
  """

  test "create and delete account through graphql", %{conn: conn} do
    conn =
      post(conn, "/graphql/", %{
        "query" => @create_account_query,
        "variables" => %{
          "p" => "verycoolpassword",
          "e" => "email@email.com",
          "n" => "example name",
          "i" => "false"
        }
      })

    assert %{"createAccount" => %{"id" => id}} = json_response(conn, 200)["data"]

    conn =
      post(conn, "/graphql/", %{
        "query" => @get_account_query,
        "variables" => %{id: id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "getAccount" => %{
                 "email" => "email@email.com",
                 "name" => "example name"
               }
             }
           }

    conn =
      post(conn, "/graphql/", %{
        "query" => @delete_account_query,
        "variables" => %{id: id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "deleteAccount" => %{
                 "id" => id
               }
             }
           }
  end

  test "query account through graphql", %{conn: conn} do
    conn =
      post(conn, "/graphql/", %{
        "query" => @get_account_query,
        "variables" => %{id: 1}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "getAccount" => %{
                 "name" => "darth sidious",
                 "email" => "sheev.palpatine@naboo.net"
               }
             }
           }

    conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn =
      post(conn, "/graphql/", %{
        "query" => @get_account_query,
        "variables" => %{id: id}
      })

    assert json_response(conn, 200) == %{
             "data" => %{
               "getAccount" => %{
                 "email" => "some email",
                 "name" => "some name"
               }
             }
           }
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

    test "fail when account is duplicated", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => _id} = json_response(conn, 201)["data"]

      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"message" => "account already exists"} = json_response(conn, 403)
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

    test "fail if an account does not exist", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.account_path(conn, :update, id + 5), account: @update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete an account" do
    test "delete an existing account", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.account_path(conn, :delete, id))
      assert response(conn, 200)
    end

    test "fail if an account does not exist", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.account_path(conn, :delete, id + 5))
      assert response(conn, 404)
    end
  end

  describe "list the accounts" do
    test "list all the account", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert response(conn, 200)
    end
  end

  describe "show accounts" do
    test "fail when account does not exist", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :show, 555_453))
      assert response(conn, 404)
    end
  end
end
