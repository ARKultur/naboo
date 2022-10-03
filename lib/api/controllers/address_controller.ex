defmodule NabooAPI.AddressController do
  use Phoenix.Controller, namespace: NabooAPI, root: "lib/api"
  use PhoenixSwagger

  alias Ecto.Changeset

  alias Naboo.Domain.Address
  alias Naboo.Domains

  alias NabooAPI.AddressView
  alias NabooAPI.Views.Errors

  swagger_path(:index) do
    get("api/addresses")
    summary("Lists all registered addresses")
    description("Currently, it will blindly list all existing addresses in the database")
    produces("application/json")
    deprecated(false)

    response(200, "index.json", %{},
      example: %{
        addresses: [
          %{
            id: 1,
            city: "Washington DC",
            country: "United States of America",
            country_code: "US",
            postcode: "20005",
            state_district: "Washington DC"
          },
          %{
            id: 2,
            city: "Paris",
            country: "France",
            country_code: "FR",
            postcode: "75019",
            state_district: "Paris"
          }
        ]
      }
    )
  end

  def index(conn, _params) do
    conn
    |> put_view(AddressView)
    |> put_status(:ok)
    |> render("index.json", addresses: Domains.list_addresses())
  end

  swagger_path(:create) do
    post("/api/address")
    summary("Create a address")
    description("Create a address, which should resolve an address")
    produces("application/json")
    deprecated(false)

    parameter(:address_params, :body, :Address, "informations about the address",
      required: true,
      example: %{
        address: %{
          city: "Paris",
          country: "France",
          country_code: "FR",
          postcode: "75019",
          state_district: "Paris"
        }
      }
    )

    response(200, "show.json", %{},
      example: %{
        address: %{
          id: 2,
          city: "Paris",
          country: "France",
          country_code: "FR",
          postcode: "75019",
          state_district: "Paris"
        }
      }
    )
  end

  def create(conn, %{"address" => address_params}) do
    with {:ok, %Address{} = address} <- Domains.create_address(address_params) do
      conn
      |> put_view(AddressView)
      |> put_status(:created)
      |> render("show.json", address: address)
    else
      {:error, changeset = %Changeset{}} ->
        conn
        |> put_view(Errors)
        |> put_status(403)
        |> render("error_messages.json", %{errors: changeset.errors})

      err ->
        conn
        |> put_view(Errors)
        |> put_status(500)
        |> render("error_messages.json", %{errors: err})
    end
  end

  swagger_path(:show) do
    get("/api/address/{id}")
    summary("Finds a specific address")
    description("Show a address in the database")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "address id", required: true)

    response(200, "show.json", %{},
      example: %{
        address: %{
          id: 2,
          city: "Paris",
          country: "France",
          country_code: "FR",
          postcode: "75019",
          state_district: "Paris"
        }
      }
    )
  end

  def show(conn, %{"id" => id}) do
    case Domains.get_address(id) do
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      address ->
        conn
        |> put_view(AddressView)
        |> put_status(:ok)
        |> render("show.json", address: address)
    end
  end

  swagger_path(:update) do
    patch("/api/address/{id}")
    summary("Update a address")
    description("Update a user")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :integer, "id of the address", required: true)
    parameter(:address_params, :body, :Address, "new informations of the account", required: true)

    response(200, "show.json", %{},
      example: %{
        address_params: %{
          id: 2,
          city: "Paris",
          country: "France",
          country_code: "FR",
          postcode: "75019",
          state_district: "Paris"
        }
      }
    )
  end

  def update(conn, %{"id" => id, "address" => address_params}) do
    with %Address{} = address <- Domains.get_address(id),
         {:ok, %Address{} = updated} <- Domains.update_address(address, address_params) do
      conn
      |> put_view(AddressView)
      |> put_status(:ok)
      |> render("show.json", address: updated)
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
        |> render("error_messages.json", %{errors: changeset.errors})
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/address/{id}")
    summary("Delete a address")
    description("Delete a address")
    produces("application/json")
    deprecated(false)
    parameter(:id, :path, :integer, "address id", required: true)
    response(200, "address deleted")
  end

  def delete(conn, %{"id" => id}) do
    with %Address{} = address <- Domains.get_address(id),
         {:ok, %Address{}} <- Domains.delete_address(address) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, "address deleted")
      |> halt()
    else
      nil ->
        conn
        |> put_view(Errors)
        |> put_status(:not_found)
        |> render("404.json", [])

      {:error, _} ->
        conn
        |> put_view(Errors)
        |> put_status(400)
        |> render("error_messages.json", %{errors: "Could not delete address"})
    end
  end
end
