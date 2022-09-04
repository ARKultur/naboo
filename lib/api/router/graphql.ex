defmodule NabooAPI.Router.GraphQL do
  use Plug.Router

  defmodule API do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    if Mix.env() != :prod do
      forward("/hub",
        to: Absinthe.Plug.GraphiQL,
        schema: NabooAPI.Schema,
        interface: :simple,
        context: %{pubsub: Naboo.Endpoint}
      )
    end

    plug(NabooAPI.Auth.Guardian.Pipeline)

    forward("/",
      to: Absinthe.Plug,
      init_opts: [
        document_providers: {NabooAPI, :document_providers},
        json_codec: Jason,
        schema: NabooAPI.Schema
      ]
    )
  end

    plug(:match)
    plug(:dispatch)

  forward("/graphql", to: API)

  match(_, do: conn)
end
