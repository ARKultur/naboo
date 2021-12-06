defmodule NabooGraphQL.Resolvers.AccountResolver do
  alias Naboo.Accounts
  alias Naboo.Authentication

  def all_accounts(_root, _args, _info) do
    accounts = Accounts.list_accounts()
    {:ok, accounts}
  end

  def logout(_root, %{email: email}, _do) do
    with {:ok, account} <- Accounts.get_account_by_email(email),
         true <- Accounts.is_logged_in(account) do
      Accounts.update_account(account, %{auth_token: nil})
    else
      _err -> {:error, "could not logout"}
    end
  end

  def login(_root, %{email: email, password: password}, _do) do
    with {:ok, account} <- Accounts.get_account_by_email(email),
         {:ok, _} <- Authentication.authenticate(account, password),
         token <- Authentication.generate_token() do
      Accounts.update_account(account, %{auth_token: token})
    else
      _err -> {:error, "invalid credentials"}
    end
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
