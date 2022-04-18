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
alias Naboo.Repo

%Account{}
|> Account.changeset(%{
  email: "sheev.palpatine@naboo.net",
  password: "sidious",
  is_admin: true,
  name: "darth sidious"
})
|> Repo.insert!()
