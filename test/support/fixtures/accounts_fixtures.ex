defmodule Naboo.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Naboo.Accounts` context.
  """

  alias Faker.App
  alias Faker.Internet

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        email: Internet.email(),
        password: "very secret password",
        name: App.author()
      })
      |> Naboo.Accounts.create_account()

    account
  end
end
