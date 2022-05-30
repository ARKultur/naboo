defmodule Naboo.Swagger.Tests do
  use Naboo.ConnCase

  test "GET /swagger", %{conn: conn} do
    conn = get(conn, "/swagger")

    assert response(conn, 200)
  end
end
