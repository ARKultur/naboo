defmodule Naboo.Utils do
  use Ecto.Schema
  import Ecto.Changeset

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

  def validate_point(changeset) do
    lat = get_change(changeset, :latitude)
    long = get_change(changeset, :longitude)

    params = %Geo.Point{coordinates: {long, lat}, srid: nil}

    with {:ok, _} <- params |> Geo.JSON.encode() do
      changeset
    else
      {:error, _} ->
        add_error(changeset, :latitude, "invalid values")
        add_error(changeset, :longitude, "invalid values")
    end
  end
end
