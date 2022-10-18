defmodule Naboo.Repo.Migrations.EnforceUniqueConstraints do
  use Ecto.Migration

  def change do
    create(unique_index(:accounts, [:email, :name], name: :accounts_name_email_index))
  end
end
