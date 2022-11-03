defmodule NabooAPI.Auth.Plug.SetUser do
  use Guardian.Plug.Pipeline,
    otp_app: :naboo,
    module: NabooAPI.Auth.Guardian,
    error_handler: NabooAPI.Auth.Errors

  alias Plug.Conn

  def call(conn, _opts) do
    current_user = Guardian.Plug.current_resource(conn)
    conn |> Conn.assign(:current_user, current_user)
  end
end
