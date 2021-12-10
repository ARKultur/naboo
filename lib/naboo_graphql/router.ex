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

  plug(:match)
  plug(:dispatch)
  plug(NabooWeb.Guardian.AuthPipeline)

  forward("/graphql", to: GraphQL)

  match(_, do: conn)
end
