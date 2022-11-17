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
  Registers an admin.

  ## Example

  iex> register_admin(%{"name" => "Palpatine", "email" => "sheev.palpatine@senate.galaxy",
    "password" => "anak1n"})
  %Account{}

  iex> register_admin("Some wrong value")
  {:error,  changeset = %Changeset{}}

  """
  def register_admin(account_params) do
    %Account{}
    |> Account.create_admin_changeset(account_params)
    |> Naboo.Repo.insert()
  end

  @doc """
  Registers an account.

  ## Example

  iex> register(%{"name" => "Palpatine", "email" => "sheev.palpatine@senate.galaxy",
    "password" => "anak1n"})
  %Account{}

  iex> register("Some wrong value")
  {:error,  changeset = %Changeset{}}

  """
  def register(account_params) do
    %Account{}
    |> Account.create_changeset(account_params)
    |> Naboo.Repo.insert()
  end

  @doc """
  Returns the list of accounts.

  ## Examples

  iex> list_accounts()
  [%Account{}, ...]

  iex> list_account(%{should_preload: true})
  [%Account{..., [%Node{}]}]

  """
  def list_accounts do
    Repo.all(Account)
  end

  def list_accounts(%{should_preload: false}), do: list_accounts()

  def list_accounts(%{should_preload: true}) do
    list_accounts()
    |> Repo.preload(domains: :address)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

  iex> find_by_email!(123)
  {:ok, %Account{}}

  iex> find_by_email!(456)
  Nil

  """
  def find_by_email!(email) do
    Repo.get_by(Account, email: email)
  end

  @doc """
  Get an account & fetch related nodes

  Returns nil if Account does not exist

  ## Examples

  iex > get_account_preload(123)
  %Account{}

  iex > get_account_preload(456)
  nil
  """
  def get_account_preload(id) do
    Repo.one(
      from(account in Naboo.Accounts.Account,
        where: account.id == ^id,
        preload: [domains: :address]
      )
    )
  end

  @doc """
  Safely gets a single account.

  Returns nil if the Account does not exist.

  ## Examples

  iex> get_account(123)
  %Account{}

  iex> get_account(456)
  nil

  """
  def get_account(id), do: Repo.get(Account, id)

  @doc """
  Safely gets a single account, expecting an email.

  Returns nil if the Account does not exist.

  ## Examples

  iex> get_account_by_email(something@email.com)
  %Account{}

  iex> get_account_by_email(doesnt.exit@email.com)
  nil

  """
  def get_account_by_email(email) do
    Repo.get_by(Account, email: email)
  end

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
    |> Account.create_changeset(attrs)
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
  def update_account(nil, _attrs), do: nil

  def update_account(%Account{} = account, attrs) do
    changeset =
      if account.is_admin do
        Account.admin_changeset(account, attrs)
      else
        Account.changeset(account, attrs)
      end

    Repo.update(changeset)
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
