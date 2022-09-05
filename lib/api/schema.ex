defmodule NabooAPI.Schema do
  use Absinthe.Schema

  alias Naboo.Repo
  alias NabooAPI.Resolvers.AccountResolver
  alias NabooAPI.Resolvers.AddressResolver
  alias NabooAPI.Resolvers.NodeResolver

  import_types(Absinthe.Type.Custom)
  import_types(NabooAPI.Application.Types)

  mutation do
    @desc "Create a new address"
    field :create_address, :address do
      arg(:city, non_null(:string))
      arg(:country, non_null(:string))
      arg(:country_code, non_null(:string))
      arg(:postcode, non_null(:string))
      arg(:state, non_null(:string))
      arg(:state_district, non_null(:string))

      resolve(&AddressResolver.create_address/3)
    end

    @desc "Update an address"
    field :update_address, :address do
      arg(:city, non_null(:string))
      arg(:country, non_null(:string))
      arg(:country_code, non_null(:string))
      arg(:postcode, non_null(:string))
      arg(:state, non_null(:string))
      arg(:state_district, non_null(:string))
      arg(:id, non_null(:id))

      resolve(&AddressResolver.update_address/3)
    end

    @desc "Delete an address"
    field :delete_address, :address do
      arg(:id, non_null(:id))

      resolve(&AddressResolver.delete_address/3)
    end

    @desc "Create a new node"
    field :create_node, :node do
      arg(:latitude, non_null(:string))
      arg(:longitude, non_null(:string))
      arg(:name, non_null(:string))
      arg(:addr_id, non_null(:id))

      resolve(&NodeResolver.create_node/3)
    end

    @desc "Updates existing node"
    field :update_node, :node do
      arg(:id, non_null(:id))
      arg(:latitude, non_null(:string))
      arg(:longitude, non_null(:string))
      arg(:name, non_null(:string))
      arg(:addr_id, non_null(:id))

      resolve(&NodeResolver.update_node/3)
    end

    @desc "Delete an node"
    field :delete_node, :node do
      arg(:id, non_null(:id))

      resolve(&NodeResolver.delete_node/3)
    end

    @desc "Create a new account"
    field :create_account, :account do
      arg(:password, non_null(:string))
      arg(:email, non_null(:string))
      arg(:name, non_null(:string))
      arg(:is_admin, non_null(:string))

      resolve(&AccountResolver.create_account/3)
    end

    @desc "Updates existing account"
    field :update_account, :account do
      arg(:id, non_null(:id))
      arg(:password, non_null(:string))
      arg(:email, non_null(:string))
      arg(:name, non_null(:string))
      arg(:is_admin, non_null(:string))

      resolve(&AccountResolver.update_account/3)
    end

    @desc "Delete an account"
    field :delete_account, :account do
      arg(:id, non_null(:id))

      resolve(&AccountResolver.delete_account/3)
    end
  end

  query do
    import_fields(:application_queries)

    @desc "get single account"
    field :get_account, :account do
      arg(:id, non_null(:id))

      resolve(&AccountResolver.get_account/3)
    end

    @desc "get all accounts"
    field :all_accounts, non_null(list_of(non_null(:account))) do
      resolve(&AccountResolver.all_accounts/3)
    end

    @desc "get single address"
    field :get_address, :address do
      arg(:id, non_null(:id))

      resolve(&AddressResolver.get_address/3)
    end

    @desc "get all addresses"
    field :all_addresses, non_null(list_of(non_null(:address))) do
      resolve(&AddressResolver.all_addresses/3)
    end

    @desc "get single node"
    field :get_node, :node do
      arg(:id, non_null(:id))

      resolve(&NodeResolver.get_node/3)
    end

    @desc "get all nodes"
    field :all_nodes, non_null(list_of(non_null(:node))) do
      resolve(&NodeResolver.all_nodes/3)
    end
  end

  object :node do
    field(:latitude, non_null(:string))
    field(:longitude, non_null(:string))
    field(:name, non_null(:string))
    field(:addr_id, non_null(:id))
  end

  object :address do
    field(:city, non_null(:string))
    field(:country, non_null(:string))
    field(:country_code, non_null(:string))
    field(:postcode, non_null(:string))
    field(:state, non_null(:string))
    field(:state_district, non_null(:string))
  end

  object :account do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
    field(:name, non_null(:string))
    field(:is_admin, non_null(:string))
  end

  def context(context) do
    Map.put(context, :loader, Dataloader.add_source(Dataloader.new(), Repo, Dataloader.Ecto.new(Repo)))
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _, _) do
    [NewRelic.Absinthe.Middleware] ++ middleware
  end
end
