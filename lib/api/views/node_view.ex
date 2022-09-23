defmodule NabooAPI.NodeView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.NodeView

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
      address: %{
        city: node.address.city,
        country: node.address.country,
        country_code: node.address.country_code,
        postcode: node.address.postcode,
        state: node.address.state,
        state_district: node.address.state_district
      }
    }
  end
end
