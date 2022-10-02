defmodule NabooAPI.NodeController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Naboo.Domain.Node
  alias Naboo.Domains

  alias NabooAPI.NodeView
  alias NabooAPI.Views.Errors

  swagger_path(:index) do
    get("api/nodes")
    summary("Lists all registered nodes")
    description("Currently, it will blindly list all existing nodes in the database")
    produces("application/json")
    deprecated(false)

    response(200, "index.json", %{},
      example: %{
        nodes: [
          %{
            id: 1,
            latitude: "38.8951",
            longitude: "-77.0364",
            name: "washington dc"
          },
          %{
            id: 2,
            latitude: "48.8584",
            longitude: "2.2945",
            name: "eiffel tower"
          }
        ]
      }
    )
  end

  def index(conn, _params) do
    conn
    |> put_view(NodeView)
    |> put_status(:ok)
    |> render("index.json", nodes: Domains.list_nodes())
  end

  swagger_path(:create) do
    post("/api/node")
    summary("Create a node")
    description("Create a node, which should resolve an address")
    produces("application/json")
    deprecated(false)

    parameter(:node_params, :body, :Node, "informations about the node",
      required: true,
      example: %{
        node: %{
          latitude: "38.8951",
          longitude: "-77.0364",
          name: "washington dc",
          address_id: 1
        }
      }
    )

    response(200, "show.json", %{},
      example: %{
        node: %{
          id: 1,
          latitude: "38.8951",
          longitude: "-77.0364",
          name: "washington dc"
        }
      }
    )
  end

  def create(conn, %{"node" => node_params}) do
    with {:ok, %Node{} = node} <- Domains.create_node(node_params) do
      conn
      |> put_view(NodeView)
      |> put_status(:created)
      |> render("show.json", node: node)
    else
      {:error, changeset} ->
        conn
        |> put_view(Errors)
        |> put_status(:forbidden)
        |> render("error_messages.json", %{error: changeset})

      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:forbidden)
        |> render("error_messages.json", %{error: "input not acceptable"})
    end
  end

  swagger_path(:show) do
    get("/api/node/{id}")
    summary("Finds a specific node")
    description("Show a node in the database")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "node id", required: true)

    response(200, "show.json", %{},
      example: %{
        node: %{
          id: 1,
          latitude: "38.8951",
          longitude: "-77.0364",
          name: "washington dc"
        }
      }
    )
  end

  def show(conn, %{"id" => id}) do
    case Domains.get_node(id) do
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      node ->
        conn
        |> put_view(NodeView)
        |> put_status(:ok)
        |> render("show.json", node: node)
    end
  end

  swagger_path(:update) do
    patch("/api/node/{id}")
    summary("Update a node")
    description("Update a user")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :integer, "id of the node", required: true)
    parameter(:node_params, :body, :Node, "new informations of the account", required: true)

    response(200, "show.json", %{},
      example: %{
        node_params: %{
          id: 1,
          latitude: "38.8951",
          longitude: "-77.0364",
          name: "Washington DC"
        }
      }
    )
  end

  def update(conn, %{"id" => id, "node" => node_params}) do
    with %Node{} = node <- Domains.get_node(id),
         {:ok, %Node{} = updated} <- Domains.update_node(node, node_params) do
      conn
      |> put_view(NodeView)
      |> put_status(:ok)
      |> render("show.json", node: updated)
    else
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      {:error, changeset} ->
        conn
        |> put_view(Errors)
        |> put_status(400)
        |> render("error_messages.json", %{errors: changeset})

      err ->
        conn
        |> put_view(Errors)
        |> put_status(403)
        |> render("error_messages.json", %{errors: err})
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/node/{id}")
    summary("Delete a node")
    description("Delete a node")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "node id", required: true)
    response(200, "node deleted")
  end

  def delete(conn, %{"id" => id}) do
    with %Node{} = node <- Domains.get_node(id),
         {:ok, %Node{}} <- Domains.delete_node(node) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "node deleted")
      |> halt()
    else
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      {:ko, _} ->
        conn
        |> put_view(Errors)
        |> put_status(400)
        |> render("error_messages.json", %{errors: "Could not delete node"})
    end
  end
end
