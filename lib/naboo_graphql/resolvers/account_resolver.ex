defmodule NabooGraphQL.Resolvers.AccountResolver do
  alias Naboo.Accounts

  def all_accounts(_root, _args, _info) do
    accounts = Accounts.list_accounts()
    {:ok, accounts}
  end

  def get_user(_root, %{id: id}, _do) do
    Accounts.get_account(id)
  end

  def delete_account(_root, %{id: id}, _info) do
    case Accounts.get_account!(id) do
      {:ok, account} ->
        Accounts.delete_account(account)

      _ ->
        {:error, "could not find account"}
    end
  end

  def create_account(_root, args, _info) do
    case Accounts.create_account(args) do
      {:ok, account} ->
        {:ok, account}

      _error ->
        {:error, "could not create account"}
    end
  end
end
