defmodule NabooAPI.GeoJsonController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  alias NabooAPI.Views.Errors

  require Logger

  def validate_route(conn, params) do
    Logger.info("debugging #{inspect(params)}")

    with {:ok, data} <- params |> Geo.JSON.decode() do
      Logger.info("debugging #{inspect(data)}")

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "valid data")
      |> halt()
    else
      {:error, %{message: message}} ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("error_messages.json", errors: message)
    end
  end
end
