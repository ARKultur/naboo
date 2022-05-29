defmodule Naboo.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :naboo
  alias Plug.Conn
  require Logger

  @plug_ssl Plug.SSL.init(rewrite_on: [:x_forwarded_proto])

  socket("/socket", Naboo.Socket)

  plug(:ping)
  plug(:force_ssl)
  plug(:cors)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :naboo,
    gzip: true,
    only: ~w(robots.txt)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)

    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Sentry.PlugContext)
  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(NabooHealth.Router)
  plug(NabooAPI.Router.GraphQL)
  plug(NabooAPI.Router.Swagger)
  plug(:halt_if_sent)
  plug(NabooAPI.Router.Urls)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = Application.get_env(:naboo, __MODULE__)[:http][:port] || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end

  # sobelow_skip ["XSS.SendResp"]
  defp ping(%{request_path: "/ping"} = conn, _opts) do
    version = Application.get_env(:naboo, :version)
    response = Jason.encode!(%{status: "pong", version: version})

    conn
    |> Conn.put_resp_header("content-type", "application/json")
    |> Conn.send_resp(200, response)
    |> Conn.halt()
  end

  defp ping(conn, _opts), do: conn

  defp force_ssl(%{request_path: "/health"} = conn, _opts), do: conn

  defp force_ssl(conn, _opts) do
    if Application.get_env(:naboo, :force_ssl) do
      Plug.SSL.call(conn, @plug_ssl)
    else
      conn
    end
  end

  defp cors(conn, _opts) do
    opts = Corsica.init(Application.get_env(:naboo, Corsica))

    Corsica.call(conn, opts)
  end

  # Splitting routers in separate modules has a negative side effect:
  # Phoenix.Router does not check the Plug.Conn state and tries to match the
  # route even if it was already handled/sent by another router.
  defp halt_if_sent(%{state: :sent, halted: false} = conn, _opts), do: halt(conn)
  defp halt_if_sent(conn, _opts), do: conn
end
