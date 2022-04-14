defmodule NabooAPI.Resolvers.AccountResolver do
  alias Naboo.Accounts.Controller

  def all_accounts(_root, _args, _info) do
    accounts = Controller.list_accounts()
    {:ok, accounts}
  end

  def get_user(_root, %{id: id}, _do) do
    Controller.get_account(id)
  end

  def delete_account(_root, %{id: id}, _info) do
    case Controller.get_account!(id) do
      {:ok, account} ->
        Controller.delete_account(account)

      _ ->
        {:error, "could not find account"}
    end
  end

  def create_account(_root, args, _info) do
    case Controller.create_account(args) do
      {:ok, account} ->
        {:ok, account}

      _error ->
        {:error, "could not create account"}
    end
  end
end
