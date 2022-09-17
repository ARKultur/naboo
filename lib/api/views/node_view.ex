defmodule NabooAPI.NodeView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.NodeView

  def render("index.json", %{nodes: nodes}) do
    %{data: render_many(nodes, NodeView, "domain.json")}
  end

  def render("show.json", %{nodes: nodes}) do
    %{data: render_one(nodes, NodeView, "domain.json")}
  end

  def render("node.json", %{node: node}) do
    # TODO(bogdan): render address object from this view (we should have a ForeignKey here)

    %{
      id: node.id,
      latitude: node.latitude,
      longitude: node.longitude,
      name: node.name,
    }
  end
end
