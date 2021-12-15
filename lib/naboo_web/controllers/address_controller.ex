defmodule NabooWeb.AddressController do
  use Phoenix.Controller

  alias Naboo.Map.Address
  alias Naboo.Maps
  alias NabooWeb.Router.Helpers

  def index(conn, _params) do
    addresses = Maps.list_addresses()
    render(conn, "index.json", addresses: addresses)
  end

  def create(conn, %{"address" => addr_params}) do
    with {:ok, %Address{} = address} <- Maps.create_address(addr_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Helpers.address_path(conn, :show, address))
      |> render("show.json", address: address)
    end
  end

  def show(conn, %{"id" => id}) do
    address = Maps.get_address!(id)
    render(conn, "show.json", address: address)
  end

  def update(conn, %{"id" => id, "address" => addr_params}) do
    address = Maps.get_address!(id)

    with {:ok, %Address{} = addr} <- Maps.update_address(address, addr_params) do
      render(conn, "show.json", address: addr)
    end
  end

  def delete(conn, %{"id" => id}) do
    address = Maps.get_address!(id)

    with {:ok, %Address{}} <- Maps.delete_address(address) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "address deleted")
      |> halt()
    end
  end
end
