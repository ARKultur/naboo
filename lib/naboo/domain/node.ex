defmodule Naboo.Domain.Node do
  use Ecto.Schema
  import Ecto.Changeset

  import Naboo.Utils

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
    |> cast(map_castable(attrs), [:name, :latitude, :longitude])
    |> cast_assoc(:address, with: &Naboo.Domain.Address.changeset/2)
    |> foreign_key_constraint(:addresses, name: :addresses_node_id_fkey, message: "No such address exists")
    |> validate_required([:name, :latitude, :longitude, :address])
    |> validate_point()
  end
end
