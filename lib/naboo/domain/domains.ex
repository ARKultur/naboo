defmodule Naboo.Domains do
  @moduledoc """
  The Domain context.
  """

  import Ecto.Query, warn: false
  alias Naboo.Repo

  alias Naboo.Domain.Address

  @doc """
  Returns the list of all addresses.

  ## Examples

  iex> list_addresses()
  [%Address{}, ...]

  """
  def list_addresses(), do: Repo.all(Address)

  @doc """
  Safely gets a single address.

  Returns nil if the Address does not exist.

  ## Examples

  iex> get_address(123)
  %Address{}

  iex> get_address!(456)
  nil

  """
  def get_address(id), do: Repo.get(Address, id)

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

  iex> get_address!(123)
  %Address{}

  iex> get_address!(456)
  ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  @doc """
  Creates a address.

  ## Examples

  iex> create_address(%{field: value})
  {:ok, %Address{}}

  iex> create_address(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

  iex> update_address(address, %{field: new_value})
  {:ok, %Address{}}

  iex> update_address(address, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a address.

  ## Examples

  iex> delete_address(address)
  {:ok, %Address{}}

  iex> delete_address(address)
  {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

  iex> change_address(address)
  %Ecto.Changeset{data: %Address{}}

  """
  def change_address(%Address{} = address, attrs \\ %{}) do
    Address.changeset(address, attrs)
  end
end
