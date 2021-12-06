defmodule Naboo.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add(:email, :string)
      add(:encrypted_password, :string)
      add(:name, :string)
      add(:auth_token, :string)
      add(:is_admin, :boolean, default: false, null: false)

      timestamps()
    end
  end
end
