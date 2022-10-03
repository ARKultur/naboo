defmodule NabooAPI.GeoJsonControllerTest do
  use Naboo.ConnCase

  describe "test different geojson data" do
    test "geojson data is valid", %{conn: conn} do
      json = Jason.decode!("{ \"type\": \"Point\", \"coordinates\": [100.0, 0.0] }")

      conn = post(conn, "/api/rfc7946-compliance", json)
      assert _response = response(conn, 200)
    end

    test "data is not valid", %{conn: conn} do
      json = Jason.decode!("{ \"type\": \"Point\", \"coordinates\": \"test\"}")

      conn = post(conn, "/api/rfc7946-compliance", json)
      assert _response = json_response(conn, 404)
    end
  end
end
