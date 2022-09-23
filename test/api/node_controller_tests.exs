defmodule NabooAPI.NodeControllerTest do
  use Naboo.ConnCase

  import Naboo.DomainsFixtures

  alias Naboo.Accounts
  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Router.Urls.Helpers

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
      address = address_fixture()

      attrs = %{
        addr_id: address.id,
        name: "washington dc",
        longitude: "-77.0364",
        latitude: "38.8951"
      }

      conn = post(conn, Helpers.node_path(conn, :create), node: attrs)
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
      assert _response = json_response(conn, 403)
    end
  end

  describe "update a node" do
    test "updates an existing node, then displays it", %{conn: conn} do
      node = node_fixture()

      conn = get(conn, Helpers.node_path(conn, :show, node.id))

      assert %{
               "id" => node.id,
               "latitude" => "some latitude",
               "longitude" => "some longitude",
               "name" => "some name",
               "address" => %{
                 "city" => "some city",
                 "country" => "some country",
                 "country_code" => "some country_code",
                 "postcode" => "some postcode",
                 "state" => "some state",
                 "state_district" => "some state_district"
               }
             } == json_response(conn, 200)["data"]

      conn = patch(conn, Helpers.node_path(conn, :update, node.id), node: @update_attrs)

      assert %{
               "id" => node.id,
               "latitude" => "some latitude",
               "longitude" => "some longitude",
               "name" => "Washington DC",
               "address" => %{
                 "city" => "some city",
                 "country" => "some country",
                 "country_code" => "some country_code",
                 "postcode" => "some postcode",
                 "state" => "some state",
                 "state_district" => "some state_district"
               }
             } == json_response(conn, 200)["data"]
    end

    test "fail if node does not exist", %{conn: conn} do
      node = node_fixture()

      conn = patch(conn, Helpers.node_path(conn, :update, node.id + 5), node: @update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete a node" do
    test "delete an exising node", %{conn: conn} do
      node = node_fixture()

      conn = delete(conn, Helpers.node_path(conn, :delete, node.id))
      assert response(conn, 200)
    end

    test "fail if an node does not exist", %{conn: conn} do
      node = node_fixture()

      conn = delete(conn, Helpers.node_path(conn, :delete, node.id + 5))
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

    test "show an existing node", %{conn: conn} do
      node = node_fixture()

      conn = get(conn, Helpers.node_path(conn, :show, node.id))

      assert %{
               "id" => node.id,
               "latitude" => node.latitude,
               "longitude" => node.longitude,
               "name" => node.name,
               "address" => %{
                 "city" => "some city",
                 "country" => "some country",
                 "country_code" => "some country_code",
                 "postcode" => "some postcode",
                 "state" => "some state",
                 "state_district" => "some state_district"
               }
             } == json_response(conn, 200)["data"]
    end
  end
end
