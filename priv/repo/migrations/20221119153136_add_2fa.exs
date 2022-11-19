defmodule Naboo.Repo.Migrations.Add2fa do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add(:has_2fa, :boolean, default: false)
    end
  end
end
