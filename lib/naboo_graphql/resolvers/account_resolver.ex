defmodule NabooGraphQL.Resolvers.AccountResolver do
  alias Naboo.Accounts

  def all_accounts(_root, _args, _info) do
    accounts = Accounts.list_accounts()
    {:ok, accounts}
  end
end
