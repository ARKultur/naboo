defmodule Naboo.Repo.Migrations.UserToDomainForeignKeys do
  use Ecto.Migration

  def change do
    alter table(:nodes) do
      add(:account_id, references(:accounts, on_delete: :delete_all))
    end

    alter table(:accounts) do
      add(:nodes_id, references(:nodes, on_delete: :delete_all))
    end
  end
end
