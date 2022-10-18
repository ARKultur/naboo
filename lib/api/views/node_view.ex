defmodule NabooAPI.NodeView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.{NodeView, AddressView}

  def render("index.json", %{nodes: nodes}) do
    %{data: render_many(nodes, NodeView, "node.json")}
  end

  def render("show.json", %{node: node}) do
    %{data: render_one(node, NodeView, "node.json")}
  end

  def render("show.json", %{nodes: nodes}) do
    %{data: render_many(nodes, NodeView, "node.json")}
  end

  def render("node.json", %{node: node}) do
    %{
      id: node.id,
      latitude: node.latitude,
      longitude: node.longitude,
      name: node.name,
      address: render_one(node.address, AddressView, "address.json")
    }
  end
end
