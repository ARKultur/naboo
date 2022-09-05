defmodule NabooAPI.Resolvers.AccountResolver do
  alias Naboo.Accounts
  alias Naboo.Accounts.Account

  def all_accounts(_root, _args, _info) do
    {:ok, Accounts.list_accounts()}
  end

  def get_account(_root, %{id: id}, _do) do
    {:ok, Accounts.get_account(id)}
  end

  def update_account(_root, args, _info) do
    with %Account{} = account <- Accounts.get_account(args.id),
         {:ok, updated} <- Accounts.update_account(account, args) do
      {:ok, updated}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _ ->
        {:error, :invalid_attrs}
    end
  end

  def delete_account(_root, %{id: id}, _info) do
    case Accounts.get_account(id) do
      nil ->
        {:error, "could not find account"}

      account ->
        Accounts.delete_account(account)
    end
  end

  def create_account(_root, args, _info) do
    args
    |> Map.replace(:is_admin, String.to_atom(args[:is_admin]))
    |> Accounts.create_account()
  end
end
