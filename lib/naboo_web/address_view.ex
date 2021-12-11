defmodule NabooWeb.AddressView do
  use Phoenix.View, root: "lib/naboo_web", path: "home/templates", namespace: NabooWeb
  alias NabooWeb.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "address.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, AddressView, "address.json")}
  end

  def render("address.json", %{address: address}) do
    %{
      id: address.id,
      state: address.state,
      state_district: address.state_district,
      postcode: address.postcode,
      country_code: address.country_code,
      city: address.city,
      country: address.country
    }
  end
end
