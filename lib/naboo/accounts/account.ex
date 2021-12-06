defmodule Naboo.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:email, :string)

    # TODO actually encrypt the password lol
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)

    field(:is_admin, :boolean, default: false)
    field(:name, :string)
    field(:auth_token, :string)

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :encrypted_password, :name, :is_admin, :auth_token])
    |> validate_required([:email, :encrypted_password, :name])
  end
end
