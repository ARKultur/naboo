defmodule Naboo.Map.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field(:city, :string)
    field(:country, :string)
    field(:country_code, :string)
    field(:postcode, :string)
    field(:state, :string)
    field(:state_district, :string)
    field(:display_name, :string)
    field(:latitude, :string)
    field(:longitude, :string)
    field(:osm_id, :string)
    field(:place_id, :string)

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:city, :state_district, :state, :postcode, :country, :country_code, :display_name, :latitude, :longitude, :osm_id, :place_id])
    |> validate_required([:city, :state_district, :state, :postcode, :country, :country_code, :display_name, :latitude, :longitude, :osm_id, :place_id])
  end
end
