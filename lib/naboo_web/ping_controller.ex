defmodule NabooWeb.PingController do
  use Phoenix.Controller

  def index(conn, _params), do: send_resp(conn, 200, "pong!")
end
