defmodule NabooGraphQL.Router do
  use Plug.Router

  defmodule GraphQL do
    use Plug.Router

    plug(:match)
    plug(:dispatch)

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
