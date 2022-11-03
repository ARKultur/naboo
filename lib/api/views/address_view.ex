defmodule NabooAPI.AddressView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "domain.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, AddressView, "address.json")}
  end

  def render("address.json", %{address: address}) do
    %{
      id: address.id,
      city: address.city,
      country: address.country,
      country_code: address.country_code,
      postcode: address.postcode,
      state: address.state,
      state_district: address.state_district
    }
  end
end
