defmodule Naboo.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add(:city, :string)
      add(:country, :string)
      add(:country_code, :string)
      add(:postcode, :string)
      add(:state, :string)
      add(:state_district, :string)

      timestamps()
    end
  end
end
