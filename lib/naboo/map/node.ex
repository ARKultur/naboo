defmodule Naboo.Map.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field(:display_name, :string)
    field(:latitude, :string)
    field(:longitude, :string)
    field(:osm_id, :string)
    field(:place_id, :string)
    field(:address_id, :id)

    timestamps()
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:place_id, :osm_id, :latitude, :longitude, :display_name])
    |> validate_required([:place_id, :osm_id, :latitude, :longitude, :display_name])
  end
end
