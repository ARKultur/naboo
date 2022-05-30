defmodule Naboo.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes) do
      add(:name, :string)
      add(:latitude, :string)
      add(:longitude, :string)
      add(:addr_id, references(:addresses, on_delete: :nothing))

      timestamps()
    end

    create(index(:nodes, [:addr_id]))
  end
end
