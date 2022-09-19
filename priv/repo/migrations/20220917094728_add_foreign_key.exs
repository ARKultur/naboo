defmodule Naboo.Repo.Migrations.AddForeignKey do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :node_id, references :nodes
    end

    create unique_index :addresses, [:node_id]
  end
end
