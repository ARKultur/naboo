defmodule Naboo.DomainsTest do
  use Naboo.DataCase

  alias Naboo.Domains

  describe "addresss" do
    alias Naboo.Domain.Address

    import Naboo.DomainsFixtures

    @invalid_attrs %{city: nil, country: nil, country_code: nil, postcode: nil, state: nil, state_district: nil}

    test "list_addresses/0 returns all addresses" do
      assert Domains.list_addresses() != nil
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Domains.get_address!(address.id).id == address.id
    end

    test "create_address/1 with valid data creates a address" do
      valid_attrs = %{
        city: "some city",
        country: "some country",
        country_code: "some country_code",
        postcode: "some postcode",
        state: "some state",
        state_district: "some state district"
      }

      assert {:ok, %Address{} = address} = Domains.create_address(valid_attrs)
      assert address.city == "some city"
      assert address.country == "some country"
      assert address.country_code == "some country_code"
      assert address.postcode == "some postcode"
      assert address.state == "some state"
      assert address.state_district == "some state district"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Domains.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()

      update_attrs = %{
        city: "some updated city",
        country: "some updated country",
        country_code: "some updated country_code",
        postcode: "some updated postcode",
        state: "some updated state",
        state_district: "some updated state district"
      }

      assert {:ok, %Address{} = address} = Domains.update_address(address, update_attrs)
      assert address.city == "some updated city"
      assert address.country == "some updated country"
      assert address.country_code == "some updated country_code"
      assert address.postcode == "some updated postcode"
      assert address.state == "some updated state"
      assert address.state_district == "some updated state district"
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
end
