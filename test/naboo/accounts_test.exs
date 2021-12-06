defmodule Naboo.AccountsTest do
  use Naboo.DataCase

  alias Naboo.Accounts

  describe "accounts" do
    alias Naboo.Accounts.Account

    import Naboo.AccountsFixtures

    @invalid_attrs %{email: nil, encrypted_password: nil, is_admin: nil, name: nil, auth_token: nil}

    test "list_accounts/0 returns all accounts" do
      assert Accounts.list_accounts() != nil
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{email: "some email", encrypted_password: "some encrypted_password", is_admin: true, name: "some name", auth_token: "some auth_token"}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.email == "some email"
      assert account.encrypted_password == "some encrypted_password"
      assert account.is_admin == true
      assert account.name == "some name"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()

      update_attrs = %{
        email: "some updated email",
        encrypted_password: "some updated encrypted_password",
        is_admin: false,
        name: "some updated name",
        auth_token: "some auth_token"
      }

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.email == "some updated email"
      assert account.encrypted_password == "some updated encrypted_password"
      assert account.is_admin == false
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end
end
