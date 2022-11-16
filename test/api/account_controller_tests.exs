defmodule NabooAPI.AccountControllerTest do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    "email" => "email@email.com",
    "password" => "some password",
    "password_confirmation" => "some password",
    "name" => "some name"
  }

  @update_attrs %{
    "email" => "updated.email@email.com",
    "password" => "some updated password",
    "password_confirmation" => "some updated password",
    "name" => "some updated name"
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
                 "email" => "email@email.com",
                 "name" => "some name"
               }
             }
           }
  end

  describe "create account" do
    import Naboo.DomainsFixtures

    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Helpers.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "email@email.com",
               "is_admin" => false,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders account with created node when requested from user", %{conn: conn} do
      _node = node_fixture(%{account_id: 1})

      conn = get(conn, Helpers.account_path(conn, :index), preload_nodes: true)

      assert %{
               "id" => 1,
               "email" => "sheev.palpatine@naboo.net",
               "is_admin" => true,
               "name" => "darth sidious"
             } = json_response(conn, 200)["data"]
    end

    test "fail when account is duplicated", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => _id} = json_response(conn, 201)["data"]

      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"errors" => [%{"detail" => "has already been taken", "field" => "name"}]} = json_response(conn, 403)
    end

    test "fail when account data is completely invalid", %{conn: conn} do
      attrs = %{
        hello: "world",
        testvalue: 1234,
        gaming: true
      }

      conn = post(conn, Helpers.account_path(conn, :create), account: attrs)

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
        "password" => "very cool password",
        "password_confirmation" => "very cool password"
      }

      conn = post(conn, Helpers.account_path(conn, :create), account: args)

      assert %{
               "errors" => [%{"detail" => "has invalid format", "field" => "email"}]
             } = json_response(conn, 403)
    end
  end

  describe "update an account" do
    test "renders updated account when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.account_path(conn, :update, id), account: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Helpers.account_path(conn, :index))

      assert %{
               "id" => ^id,
               "email" => "updated.email@email.com",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "fail if we want to update with invalid", %{conn: conn} do
      conn = post(conn, Helpers.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      invalid_attrs = %{
        email: "invalid email"
      }

      conn = patch(conn, Helpers.account_path(conn, :update, id), account: invalid_attrs)
      assert "Could not update account" = json_response(conn, 400)["errors"]
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

  describe "list the accounts" do
    test "list all the account", %{conn: conn} do
      conn = get(conn, Helpers.account_path(conn, :index))
      assert response(conn, 200)
    end
  end
end
