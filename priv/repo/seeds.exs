# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Naboo.Repo.insert!(%Naboo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Naboo.Accounts.Account
alias Naboo.Map.Address
alias Naboo.Repo

%Account{}
|> Account.changeset(%{
  email: "sheev.palpatine@naboo.net",
  password: "sidious",
  is_admin: true,
  name: "darth sidious"
})
|> Repo.insert!()

%Address{}
|> Address.changeset(%{
  city: "Lyon",
  country: "France",
  display_name: "Hotel Dieu",
  longitude: "4.8370",
  latitude: "45.7590",
  country_code: "placeholder",
  postcode: "placeholder",
  state: "placeholder",
  state_district: "placeholder",
  osm_id: "placeholder",
  place_id: "placeholder",
  description: "placeholder"
})
|> Repo.insert!()

%Address{}
|> Address.changeset(%{
  city: "Lyon",
  country: "France",
  display_name: "Place Bellecour",
  longitude: "4.8320",
  latitude: "45.7576",
  country_code: "placeholder",
  postcode: "placeholder",
  state: "placeholder",
  state_district: "placeholder",
  osm_id: "placeholder",
  place_id: "placeholder",
  description: "placeholder"
})
|> Repo.insert!()

%Address{}
|> Address.changeset(%{
  city: "Paris",
  country: "France",
  display_name: "Tour Eiffel",
  longitude: "2.2945",
  latitude: "48.8584",
  country_code: "placeholder",
  postcode: "placeholder",
  state: "placeholder",
  state_district: "placeholder",
  osm_id: "placeholder",
  place_id: "placeholder",
  description: "placeholder"
})
|> Repo.insert!()
