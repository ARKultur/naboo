defmodule NabooGraphQL.Router do
  use Plug.Router

  defmodule GraphQL do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    if Mix.env() != :prod do
      forward("/hub",
        to: Absinthe.Plug.GraphiQL,
        schema: NabooGraphQL.Schema,
        interface: :simple,
        context: %{pubsub: NabooWeb.Endpoint}
      )
    end

    forward("/",
      to: Absinthe.Plug,
      init_opts: [
        document_providers: {NabooGraphQL, :document_providers},
        json_codec: Jason,
        schema: NabooGraphQL.Schema
      ]
    )
  end

  plug(NabooGraphQL.Plugs.Context)

  plug(:match)
  plug(:dispatch)

  forward("/graphql", to: GraphQL)

  match(_, do: conn)
end
