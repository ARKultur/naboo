defmodule NabooAPI.Auth.Errors do
  @behaviour Guardian.Plug.ErrorHandler

  import Plug.Conn

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    # Yes, this is ugly. No, I do not care. It works. Fuck you.

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, "{\"errors\": \"authentication error\"}")
    |> halt()
  end
end
