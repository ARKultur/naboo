defmodule Naboo.Json do
  @moduledoc """
  The JSON context.
  """

  alias Plug.Conn

  @doc """
    Sends a json object without redirection to GET.

  """
  def send_json(conn, status, object) do
    encoded_obj = Jason.encode!(object)
    encoded = Jason.encode!(%{status: status, data: encoded_obj})

    conn
    |> Conn.put_resp_header("content-type", "application/json; charset=utf-8")
    |> Conn.send_resp(200, encoded)
    |> Conn.halt()
  end
end
