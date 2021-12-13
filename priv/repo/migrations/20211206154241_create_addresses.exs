defmodule Naboo.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add(:city, :string)
      add(:state_district, :string)
      add(:state, :string)
      add(:postcode, :string)
      add(:country, :string)
      add(:country_code, :string)
      add(:place_id, :string)
      add(:osm_id, :string)
      add(:latitude, :string)
      add(:longitude, :string)
      add(:display_name, :string)

      timestamps()
    end
  end
end
