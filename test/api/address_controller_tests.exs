defmodule NabooAPI.AddressControllerTest do
  use Naboo.ConnCase

  import Naboo.DomainsFixtures

  alias Naboo.Accounts
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    "city" => "Paris",
    "country" => "France",
    "country_code" => "FR",
    "postcode" => "75019",
    "state" => "Something",
    "state_district" => "Paris"
  }

  @bad_create_attrs %{
    "city" => "Paris",
    "country_code" => "FR",
    "postcode" => "75019",
    "state_district" => "Paris"
  }

  @update_attrs %{
    "city" => "Paris",
    "country" => "France",
    "country_code" => "FR",
    "postcode" => "75019",
    "state" => "Something else",
    "state_district" => "Seine"
  }

  setup %{conn: conn} do
    user = Accounts.get_account(1)
    {:ok, jwt, conn} = Sessions.log_in(conn, user)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, conn: conn}
  end

  @create_address_query """
    mutation CreateSimpleAddress(
      $city: String!,
      $country: String!,
      $country_code: String!,
      $postcode: String!,
      $state: String!,
      $state_district: String!
    ) {
      createAddress(
        city: $city,
        country: $country,
        countryCode: $country_code,
        postcode: $postcode,
        state: $state,
        stateDistrict: $state_district
      ) {
        id
        city
        country
        state
      }
    }
  """

  @delete_address_query """
    mutation DeleteSimpleAddress($id: ID!) {
      deleteAddress(id: $id) {
        id
      }
    }
  """

  @get_address_query """
  query findAddress($id: ID!) {
    getAddress(id: $id) {
      id
      city
      country
    }
  }
  """

  describe "GraphQL test set" do
    test "create, get and delete an address through graphql", %{conn: conn} do
      conn =
        post(conn, "/graphql", %{
          "query" => @create_address_query,
          "variables" => @create_attrs
        })

      assert %{
               "createAddress" => %{
                 "id" => id,
                 "city" => "Paris",
                 "country" => "France",
                 "state" => "Something"
               }
             } = json_response(conn, 200)["data"]

      conn =
        post(conn, "/graphql", %{
          "query" => @get_address_query,
          "variables" => %{id: id}
        })

      assert %{
               "getAddress" => %{
                 "id" => id,
                 "city" => "Paris",
                 "country" => "France"
               }
             } == json_response(conn, 200)["data"]

      conn =
        post(conn, "/graphql", %{
          "query" => @delete_address_query,
          "variables" => %{id: id}
        })

      assert %{
               "deleteAddress" => %{
                 "id" => id
               }
             } == json_response(conn, 200)["data"]
    end
  end

  describe "create address" do
    test "renders address when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.address_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "city" => "Paris",
               "country" => "France",
               "country_code" => "FR",
               "postcode" => "75019",
               "state_district" => "Paris"
             } = json_response(conn, 200)["data"]
    end

    test "fail when data is not valid", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @bad_create_attrs)
      assert _resp = json_response(conn, 403)
    end
  end

  describe "update a address" do
    test "updates an existing address, then displays it", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, Helpers.address_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "city" => "Paris",
               "country" => "France",
               "country_code" => "FR",
               "postcode" => "75019",
               "state_district" => "Paris"
             } = json_response(conn, 200)["data"]

      conn = patch(conn, Helpers.address_path(conn, :update, id), address: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Helpers.address_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "city" => "Paris",
               "country" => "France",
               "country_code" => "FR",
               "postcode" => "75019",
               "state_district" => "Seine"
             } = json_response(conn, 200)["data"]
    end

    test "fail if address does not exist", %{conn: conn} do
      addr = address_fixture()

      conn = patch(conn, Helpers.address_path(conn, :update, addr.id + 5), address: @update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete a address" do
    test "delete an exising address", %{conn: conn} do
      address = address_fixture()

      conn = delete(conn, Helpers.address_path(conn, :delete, address.id))
      assert response(conn, 200)
    end

    test "fail if an address does not exist", %{conn: conn} do
      addr = address_fixture()

      conn = delete(conn, Helpers.address_path(conn, :delete, addr.id + 5))
      assert response(conn, 404)
    end
  end

  describe "list the addresses" do
    test "list all the addresses", %{conn: conn} do
      conn = get(conn, Helpers.address_path(conn, :index))
      assert response(conn, 200)
    end
  end

  describe "show a address" do
    test "fail when address does not exist", %{conn: conn} do
      conn = get(conn, Helpers.address_path(conn, :show, 555_453))
      assert response(conn, 404)
    end
  end
end
