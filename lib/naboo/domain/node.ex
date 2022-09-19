defmodule Naboo.Domain.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field(:latitude, :string)
    field(:longitude, :string)
    field(:name, :string)

    has_one(:address, Naboo.Domain.Address)

    timestamps()
  end

  # TODO(shelton): improve validation during creation / update
  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:name, :latitude, :longitude, :addr_id])
    |> validate_required([:name, :latitude, :longitude, :addr_id])
  end
end
