defmodule Naboo.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Naboo.Accounts` context.
  """

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: "some email",
        password: "some encrypted_password",
        is_admin: true,
        name: "some name",
        auth_token: "some auth_token"
      })
      |> Naboo.Accounts.create_account()

    account
  end
end
