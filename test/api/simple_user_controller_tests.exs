defmodule NabooAPI.SimpleUserControllerTest do
  use Naboo.ConnCase

  import Naboo.AccountsFixtures
  import Naboo.DomainsFixtures

  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  setup %{conn: conn} do
    user = account_fixture()
    {:ok, jwt, conn} = Sessions.log_in(conn, user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  describe "call various endpoints as a customer" do
    test "render nodes", %{conn: conn} do
      address = address_fixture()
      addr_id = address.id

      attrs = %{
        "addr_id" => address.id,
        "name" => "washington dc",
        "longitude" => "-77.0364",
        "latitude" => "38.8951"
      }

      conn = post(conn, Helpers.node_path(conn, :create), node: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.node_path(conn, :index))

      assert [
               %{
                 "address" => %{
                   "city" => "some city",
                   "country" => "some country",
                   "country_code" => "some country_code",
                   "id" => ^addr_id,
                   "postcode" => "some postcode",
                   "state" => "some state",
                   "state_district" => "some state_district"
                 },
                 "id" => ^id,
                 "latitude" => "38.8951",
                 "longitude" => "-77.0364",
                 "name" => "washington dc"
               }
             ] = json_response(conn, 200)["data"]
    end
  end
end
