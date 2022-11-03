defmodule Naboo.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Naboo.Utils

  @derive {Jason.Encoder, only: [:is_admin, :name, :email, :updated_at]}
  schema "accounts" do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    field(:is_admin, :boolean, default: false)
    field(:name, :string)

    has_many(:domains, Naboo.Domain.Node)

    timestamps()
  end

  defp base_changeset(account, attrs) do
    account
    |> cast(map_castable(attrs), [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint([:name, :email], name: :accounts_name_email_index)
    |> validate_format(:email, ~r/@/)
  end

  defp base_create_changeset(account, attrs) do
    base_changeset(account, attrs)
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_encrypted_password()
  end

  @doc false
  def changeset(account, attrs) do
    base_changeset(account, attrs)
    |> foreign_key_constraint(:domains, name: :accounts_node_id_fkey, message: "No such domain exists")
  end

  def create_changeset(account, attrs) do
    base_create_changeset(account, attrs)
    |> foreign_key_constraint(:domains, name: :accounts_node_id_fkey, message: "No such domain exists")
  end

  def admin_changeset(account, attrs) do
    base_changeset(account, attrs)
  end

  def create_admin_changeset(account, attrs) do
    base_create_changeset(account, attrs)
    |> put_change(:is_admin, true)
  end

  defp put_encrypted_password(%{valid?: true, changes: %{password: pw}} = changeset) do
    put_change(changeset, :encrypted_password, Argon2.hash_pwd_salt(pw))
  end

  defp put_encrypted_password(changeset) do
    changeset
  end
end
