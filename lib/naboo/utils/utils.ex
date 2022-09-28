defmodule Naboo.Utils do
  @doc """
  Transforms the key of a map from string to existing atoms.

  ## Examples

  iex> map_castable(%{"hello" => 1, "world" => 2})
  %{hello: 1, world: 2}

  iex> map_castable(%{hello: 1, world: 2})
  %{hello: 1, world: 2}

  iex> map_castable(something_else)
  %{}

  """
  def map_castable(map) when is_map(map) do
    map
    |> Map.new(fn {key, val} ->
      cond do
        is_binary(key) ->
          {String.to_existing_atom(key), val}

        is_atom(key) ->
          {key, val}

        true ->
          {nil, val}
      end
    end)
  end

  def map_castable(_), do: %{}
end
