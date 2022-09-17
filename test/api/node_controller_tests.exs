defmodule NabooAPI.NodeControllerTest do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    latitude: "38.8951",
    longitude: "-77.0364",
    name: "washington dc",
    addr_id: 1
  }

  @bad_create_attrs %{
    name: "washington dc",
    addr_id: 1
  }

  @update_attrs %{
    name: "Washington DC"
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

  describe "create node" do
    test "renders node when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.node_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "latitude" => "38.8951",
               "longitude" => "-77.0364",
               "name" => "washington dc"
             } = json_response(conn, 200)["data"]
    end

    test "fail when data is not valid", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @bad_create_attrs)
      assert %{"error" => _changeset} = json_response(conn, 403)["data"]
    end
  end

  describe "update a node" do
    test "updates an existing node, then displays it", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.node_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "latitude" => "38.8951",
               "longitude" => "-77.0364",
               "name" => "washington dc"
             } = json_response(conn, 200)["data"]

      conn = patch(conn, Helpers.node_path(conn, :update, id), node: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Helpers.node_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "latitude" => "38.8951",
               "longitude" => "-77.0364",
               "name" => "Washington DC"
             } = json_response(conn, 200)["data"]
    end

    test "fail if node does not exist", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.node_path(conn, :update, id + 5), node: @update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete a node" do
    test "delete an exising node", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.node_path(conn, :delete, id))
      assert response(conn, 200)
    end

    test "fail if an node does not exist", %{conn: conn} do
      conn = post(conn, Helpers.node_path(conn, :create), node: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.node_path(conn, :delete, id + 5))
      assert response(conn, 404)
    end
  end

  describe "list the nodes" do
    test "list all the nodes", %{conn: conn} do
      conn = get(conn, Helpers.node_path(conn, :index))
      assert response(conn, 200)
    end
  end

  describe "show a node" do
    test "fail when node does not exist", %{conn: conn} do
      conn = get(conn, Helpers.node_path(conn, :show, 555_453))
      assert response(conn, 404)
    end
  end
end
