defmodule NabooAPI.Resolvers.AddressResolver do
  alias Naboo.Domains
  alias Naboo.Domain.Address

  def all_addresses(_root, _args, _info) do
    {:ok, Domains.list_addresses()}
  end

  def get_address(_root, %{id: id}, _do) do
    {:ok, Domains.get_address(id)}
  end

  def update_address(_root, args, _info) do
    with %Address{} = address <- Domains.get_address(args.id),
         {:ok, updated} <- Domains.update_address(address, args) do
      {:ok, updated}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _ ->
        {:error, :invalid_attrs}
    end
  end

  def delete_address(_root, %{id: id}, _info) do
    case Domains.get_address(id) do
      nil ->
        {:error, "could not find address"}

      address ->
        Domains.delete_address(address)
    end
  end

  def create_address(_root, args, _info) do
    Domains.create_address(args)
  end
end
