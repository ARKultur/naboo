defmodule Naboo.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add :place_id, :string
      add :osm_id, :string
      add :latitude, :string
      add :longitude, :string
      add :display_name, :string
      add :address_id, references(:addresses, on_delete: :nothing)

      timestamps()
    end

    create index(:nodes, [:address_id])
  end
end
