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
        encrypted_password: "some encrypted_password",
        is_admin: true,
        name: "some name"
      })
      |> Naboo.Accounts.create_account()

    account
  end
end
