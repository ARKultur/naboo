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

Repo.insert!(%Account{
  email: "sheev.palpatine@naboo.net",
  password: "sidious",
  is_admin: true,
  name: "darth sidious",
  auth_token: "M4y7h3F0rc3B3W17hY0u"
})
