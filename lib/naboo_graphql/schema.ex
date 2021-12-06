defmodule NabooGraphQL.Schema do
  use Absinthe.Schema

  alias Naboo.Repo
  alias NabooGraphQL.Resolvers.AccountResolver

  import_types(Absinthe.Type.Custom)
  import_types(NabooGraphQL.Application.Types)

  mutation do
    @desc "Create a new account"
    field :create_account, :account do
      arg(:password, non_null(:string))
      arg(:email, non_null(:string))
      arg(:name, non_null(:string))

      resolve(&AccountResolver.create_account/3)
    end

    @desc "Delete an account"
    field :delete_account, :account do
      arg(:id, non_null(:id))

      resolve(&AccountResolver.delete_account/3)
    end

    @desc "Logs in user and provides a fresh auth_token."
    field :login, :account do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&AccountResolver.login/3)
    end
  end

  query do
    import_fields(:application_queries)

    @desc "get all accounts"
    field :all_accounts, non_null(list_of(non_null(:account))) do
      resolve(&AccountResolver.all_accounts/3)
    end
  end

  object :account do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
    field(:name, non_null(:string))
    field(:is_admin, non_null(:string))
    field(:auth_token, non_null(:string))
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
