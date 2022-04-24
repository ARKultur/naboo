defmodule NabooAPI do
  def document_providers(_) do
    [Absinthe.Plug.DocumentProvider.Default, NabooAPI.CompiledQueries]
  end
end
