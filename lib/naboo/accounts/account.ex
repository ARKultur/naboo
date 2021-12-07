defmodule Naboo.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:is_admin, :name, :description, :updated_at]}
  schema "accounts" do
    field(:email, :string)

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
    |> cast(attrs, [:email, :password, :name, :is_admin, :auth_token])
    |> validate_required([:email, :password, :name])
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> put_encrypted_password()
  end

  defp put_encrypted_password(%{valid?: true, changes: %{password: pw}} = changeset) do
    put_change(changeset, :encrypted_password, Argon2.hash_pwd_salt(pw))
  end

  defp put_encrypted_password(changeset) do
    changeset
  end
end
