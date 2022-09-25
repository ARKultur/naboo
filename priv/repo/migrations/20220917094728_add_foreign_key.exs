defmodule Naboo.Repo.Migrations.AddForeignKey do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add(:node_id, references(:nodes, on_delete: :delete_all))
    end

    alter table(:nodes) do
      add(:address_id, references(:addresses, on_delete: :delete_all))
    end
  end
end
