defmodule NabooAPI.AddressView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "domain.json")}
  end

  def render("show.json", %{addresses: addresses}) do
    %{data: render_one(addresses, AddressView, "domain.json")}
  end

  def render("node.json", %{address: address}) do
    %{
      id: address.id,
      city: address.city,
      country_code: address.country_code,
      postcode: address.postcode,
      state: address.state,
      district: address.state_district
    }
  end
end
