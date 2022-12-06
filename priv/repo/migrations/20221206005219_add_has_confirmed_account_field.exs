defmodule Naboo.Repo.Migrations.AddHasConfirmedAccountField do
  use Ecto.Migration

  import Ecto.Query

  alias Naboo.Accounts.Account
  alias Naboo.Repo

  def change do
    alter table(:accounts) do
      add(:has_confirmed, :boolean, default: false)
    end

    flush()

    # set existing account to has_confirmed = true
    Account
    |> where([a], a.has_confirmed == false)
    |> update(set: [has_confirmed: true])
    |> Repo.update_all([])
  end
end
