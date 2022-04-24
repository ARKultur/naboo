defmodule Naboo.Health.Tests do
  use NabooAPI.ConnCase

  test "GET /health", %{conn: conn} do
    conn = get(conn, "/health")

    assert response(conn, 200)
  end
end
