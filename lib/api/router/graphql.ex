defmodule NabooAPI.Router.GraphqlAuth do
  @behaviour Plug

  alias NabooAPI.Auth.Sessions
  alias Naboo.Accounts.Account

  def init(opts) do
    opts
  end

  def call(conn, _) do
    context = build_context(conn)

    conn
    |> Absinthe.Plug.put_options(context: context)
  end

  def build_context(conn) do
    case Sessions.resource(conn) do
      %Account{} = account ->
        %{current_user: account}

      _ ->
        %{}
    end
  end
end

defmodule NabooAPI.Router.GraphQL do
  use Plug.Router

  plug(NabooAPI.Router.GraphqlAuth)
  plug(:match)
  plug(:dispatch)

  forward("/graphql",
    to: Absinthe.Plug,
    init_opts: [
      document_providers: {NabooAPI, :document_providers},
      json_codec: Jason,
      schema: NabooAPI.Schema
    ]
  )

  match(_, do: conn)
end
