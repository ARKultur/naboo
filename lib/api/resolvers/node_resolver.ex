defmodule NabooAPI.Resolvers.NodeResolver do
  alias Naboo.Domain.Node
  alias Naboo.Domains

  def all_nodes(_root, _args, _info) do
    {:ok, Domains.list_nodes()}
  end

  def get_node(_root, %{id: id}, _do) do
    {:ok, Domains.get_node(id)}
  end

  def update_node(_root, args, _info) do
    with %Node{} = node <- Domains.get_node(args.id),
         {:ok, updated} <- Domains.update_node(node, args) do
      {:ok, updated}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _ ->
        {:error, :invalid_attrs}
    end
  end

  def delete_node(_root, %{id: id}, _info) do
    case Domains.get_node(id) do
      nil ->
        {:error, "could not find node"}

      node ->
        Domains.delete_node(node)
    end
  end

  def create_node(_root, args, info) do
    args =
      args
      |> Enum.into(%{
        "account_id" => info.context.current_user.id
      })

    Domains.create_node(args)
  end
end
