defmodule NabooWeb.AddressControllerTest do
  use NabooWeb.ConnCase

  alias Naboo.Accounts
  alias NabooWeb.Guardian
  alias NabooWeb.Router.Helpers

  @create_attrs %{
    city: "some city",
    country: "some country",
    country_code: "some country_code",
    postcode: "some postcode",
    state: "some state",
    state_district: "some state_district"
  }

  @update_attrs %{
    city: "some updated city",
    country: "some updated country",
    country_code: "some updated country_code",
    postcode: "some updated postcode",
    state: "some updated state",
    state_district: "some updated state_district"
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

  describe "create an address" do
    test "create an address when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)

      assert %{
               "city" => "some city",
               "country" => "some country",
               "country_code" => "some country_code",
               "postcode" => "some postcode",
               "state" => "some state",
               "state_district" => "some state_district"
             } = json_response(conn, 201)["data"]
    end
  end

  describe "update an address" do
    test "update an address when data is valid", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = patch(conn, Helpers.address_path(conn, :update, id), address: @update_attrs)

      assert %{
               "id" => ^id,
               "city" => "some updated city",
               "country" => "some updated country",
               "country_code" => "some updated country_code",
               "postcode" => "some updated postcode",
               "state" => "some updated state",
               "state_district" => "some updated state_district"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "delete an address" do
    test "delete an existing address", %{conn: conn} do
      conn = post(conn, Helpers.address_path(conn, :create), address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = delete(conn, Helpers.address_path(conn, :delete, id))
      assert response(conn, 200)
    end
  end

  describe "list addresss" do
    test "list available addresss", %{conn: conn} do
      conn = get(conn, Helpers.address_path(conn, :index))
      assert response(conn, 200)
    end
  end
end
