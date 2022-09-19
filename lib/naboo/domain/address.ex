defmodule Naboo.Domain.Address do
  use Ecto.Schema
  import Ecto.Changeset

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

  # TODO(shelton): improve validation for each of these fields. This is good enough for now though.
  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:city, :country, :country_code, :postcode, :state, :state_district, :node_id])
    |> validate_required([:city, :country, :country_code, :postcode, :state, :state_district])
  end
end
