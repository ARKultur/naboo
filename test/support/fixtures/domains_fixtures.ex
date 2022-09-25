defmodule Naboo.DomainsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Naboo.Domains` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    {:ok, address} =
      attrs
      |> Enum.into(%{
        "city" => "some city",
        "country" => "some country",
        "country_code" => "some country_code",
        "postcode" => "some postcode",
        "state" => "some state",
        "state_district" => "some state_district"
      })
      |> Naboo.Domains.create_address()

    address
  end

  @doc """
  Generate a node.
  """
  def node_fixture(attrs \\ %{}) do
    addr = address_fixture()

    new_attrs =
      attrs
      |> Enum.into(%{
        "latitude" => "some latitude",
        "longitude" => "some longitude",
        "name" => "some name",
        "addr_id" => addr.id
      })

    {:ok, node} = Naboo.Domains.create_node(new_attrs)

    node
  end
end
