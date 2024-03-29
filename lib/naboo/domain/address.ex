defmodule Naboo.Domain.Address do
  use Ecto.Schema
  import Ecto.Changeset
  import Naboo.Utils

  @derive {Jason.Encoder, only: [:city, :country, :country_code, :postcode, :state, :state_district]}
  schema "addresses" do
    field(:city, :string)
    field(:country, :string)
    field(:country_code, :string)
    field(:postcode, :string)
    field(:state, :string)
    field(:state_district, :string)

    belongs_to(:node, Naboo.Domain.Node)

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(map_castable(attrs), [:city, :country, :country_code, :postcode, :state, :state_district, :node_id])
    |> validate_required([:city, :country, :country_code, :postcode, :state, :state_district])
  end
end
