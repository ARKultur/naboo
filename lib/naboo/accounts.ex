defmodule Naboo.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Naboo.Repo

  alias Naboo.Accounts.Account

  @doc """
  Checks if an account is logged in.

  ## Examples

    iex> is_logged_in(account_logged_in)
    true

    iex> is_logged_in(account_not_logged_in)
    false
  """
  def is_logged_in(account) do
    case account.auth_token do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> find_by_auth_token!(123)
      %Account{}

      iex> find_by_auth_token!(456)
      ** (Ecto.NoResultsError)

  """
  def find_by_auth_token!(token), do: Repo.get!(Account, auth_token: token)

  @doc """
  Safely gets a single account.

  Returns nil if the Account does not exist.

  ## Examples

      iex> get_account(123)
      %Account{}

      iex> get_account!(456)
      nil

  """
  def get_account(id), do: Repo.get(Account, id)

  @doc """
  Safely gets a single account, expecting an email.

  Returns nil if the Account does not exist.

  ## Examples

      iex> get_account(something@email.com)
      %Account{}

      iex> get_account!(doesnt.exit@email.com)
      nil

  """
  def get_account_by_email(email), do: Repo.get(Account, email: email)

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end
end
