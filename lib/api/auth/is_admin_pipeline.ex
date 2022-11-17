defmodule NabooAPI.Auth.Guardian.IsAdminPipeline do
  @behaviour Plug

  import Plug.Conn

  alias NabooAPI.Auth.Sessions

  def init(opts), do: opts

  def call(conn, _params) do
    account = Sessions.resource(conn)

    if account.is_admin do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, "{\"errors\": \"this account is not an admin\"}")
      |> halt()
    end
  end
end
