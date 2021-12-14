defmodule NabooWeb.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  import Plug.Conn

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, "authentication error")
    |> halt()
  end
end
