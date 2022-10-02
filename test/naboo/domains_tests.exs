defmodule Naboo.DomainsTest do
  use Naboo.DataCase

  alias Naboo.Domains

  describe "addresses" do
    alias Naboo.Domain.Address

    import Naboo.DomainsFixtures

    @invalid_attrs %{
      "country_code" => nil,
      "state_district" => nil
    }

    test "list_addresses/0 returns all addresses" do
      assert Domains.list_addresses() != nil
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Domains.get_address!(address.id).id == address.id
    end

    test "create_address/1 with valid data creates a address" do
      valid_attrs = %{
        "city" => "some city",
        "country" => "some country",
        "country_code" => "some country_code",
        "postcode" => "some postcode",
        "state" => "some state",
        "state_district" => "some state_district"
      }

      assert {:ok, %Address{} = address} = Domains.create_address(valid_attrs)
      assert address.city == "some city"
      assert address.country == "some country"
      assert address.country_code == "some country_code"
      assert address.postcode == "some postcode"
      assert address.state == "some state"
      assert address.state_district == "some state_district"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Domains.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()

      update_attrs = %{
        "city" => "some updated city",
        "country" => "some updated country",
        "country_code" => "some updated country_code",
        "postcode" => "some updated postcode",
        "state" => "some updated state",
        "state_district" => "some updated state_district"
      }

      assert {:ok, %Address{} = address} = Domains.update_address(address, update_attrs)
      assert address.city == "some updated city"
      assert address.country == "some updated country"
      assert address.country_code == "some updated country_code"
      assert address.postcode == "some updated postcode"
      assert address.state == "some updated state"
      assert address.state_district == "some updated state_district"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Domains.update_address(address, @invalid_attrs)
      assert address.id == Domains.get_address!(address.id).id
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Domains.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Domains.change_address(address)
    end
  end

  describe "nodes" do
    alias Naboo.Domain.Node

    import Naboo.DomainsFixtures

    @invalid_attrs %{
      "latitude" => "niqsdqsd4526l",
      "longitude" => 12,
      "name" => nil,
      "addr_id" => 1
    }

    test "list_nodes/0 returns all nodes" do
      assert Domains.list_nodes() != nil
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Domains.get_node(node.id).id == node.id
    end

    test "create_node/1 with valid data creates a node" do
      address = address_fixture()

      valid_attrs = %{
        "latitude" => "100.0",
        "longitude" => "100.0",
        "name" => "some name",
        "addr_id" => address.id
      }

      assert {:ok, %Node{} = node} = Domains.create_node(valid_attrs)
      assert node.latitude == "100.0"
      assert node.longitude == "100.0"
      assert node.name == "some name"
      assert node.address.id == address.id
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %{message: "could not find address"}} = Domains.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()

      update_attrs = %{
        "latitude" => "some updated latitude",
        "longitude" => "some updated longitude",
        "name" => "some updated name"
      }

      assert {:ok, %{}} = Domains.update_node(node, update_attrs)
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()

      assert {:error, %Ecto.Changeset{}} = Domains.update_node(node, @invalid_attrs)
      assert node.id == Domains.get_node!(node.id).id
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Domains.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Domains.change_node(node)
    end
  end
end
