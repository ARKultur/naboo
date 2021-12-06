defmodule NabooGraphQL do
  def document_providers(_) do
    [Absinthe.Plug.DocumentProvider.Default, NabooGraphQL.CompiledQueries]
  end
end
