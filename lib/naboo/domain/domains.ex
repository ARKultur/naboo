defmodule Naboo.Domains do
  @moduledoc """
  The Domain context.
  """

  import Ecto.Query, warn: false
  alias Naboo.Repo

  alias Naboo.Domain.Address
  alias Naboo.Domain.Node

  @doc """
  Returns the list of all nodes.

  ## Examples

  iex> list_nodes()
  [%Node{}, ...]

  """
  def list_nodes(), do: Repo.all(Node)

  @doc """
  Safely gets a single node.

  Returns nil if the Node does not exist.

  ## Examples

  iex> get_node(123)
  %Node{}

  iex> get_node!(456)
  nil

  """
  def get_node(id) do
    Repo.get(Node, id)
    |> Repo.preload(:address)
  end

  @doc """
  Gets a single node.

  Raises `Ecto.NoResultsError` if the Node does not exist.

  ## Examples

  iex> get_node!(123)
  %Node{}

  iex> get_node!(456)
  ** (Ecto.NoResultsError)

  """
  def get_node!(id) do
    Repo.get!(Node, id)
    |> Repo.preload(:address)
  end

  @doc """
  Creates a node.

  ## Examples

  iex> create_node(%{field: value})
  {:ok, %Node{}}

  iex> create_node(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_node(attrs) do

    with %Address{} = addr <- get_address(attrs.addr_id),
         cset <- Ecto.build_assoc(addr, :node, attrs),
         {:ok, %Node{} = node} <- Repo.insert(cset),
         {:ok, %Address{}} <- update_address(addr, %{node_id: node.id}) do

      {:ok, node}

    else
      nil ->
        {:error, %{
          message: "could not find address",
        }}

      {:error, cset} ->

        {:error, %{
          message: "could not create node",
          changeset: cset,
        }}

      err ->
        {:error, err}
    end
  end

  @doc """
  Updates a node.

  ## Examples

  iex> update_node(node, %{field: new_value})
  {:ok, %Node{}}

  iex> update_node(node, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_node(%Node{} = node, attrs) do
    node
    |> Node.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a node.

  ## Examples

  iex> delete_node(node)
  {:ok, %Node{}}

  iex> delete_node(node)
  {:error, %Ecto.Changeset{}}

  """
  def delete_node(%Node{} = node) do
    Repo.delete(node)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking node changes.

  ## Examples

  iex> change_node(node)
  %Ecto.Changeset{data: %Node{}}

  """
  def change_node(%Node{} = node, attrs \\ %{}) do
    Node.changeset(node, attrs)
  end

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
