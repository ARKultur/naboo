defmodule NabooAPI.AddressControllerTest do
  use Naboo.ConnCase

  alias Naboo.Accounts
  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Router.Urls.Helpers

  @create_attrs %{
    city: "Paris",
    country: "France",
    country_code: "FR",
    postcode: "75019",
    state_district: "Paris"
  }

  @bad_create_attrs %{
    city: "Paris",
    country: "France"
  }

  @update_attrs %{
    state_district: "Seine"
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
      assert %{"error" => _changeset} = json_response(conn, 403)["data"]
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
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.address_path(conn, :update, id + 5), address: @update_attrs)
      assert response(conn, 404)
    end
  end

  describe "delete a address" do
    test "delete an exising address", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.address_path(conn, :delete, id))
      assert response(conn, 200)
    end

    test "fail if an address does not exist", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.address_path(conn, :delete, id + 5))
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
