defmodule NabooGraphQL.Schema do
  use Absinthe.Schema

  alias Naboo.Repo
  alias NabooGraphQL.Resolvers.AccountResolver

  import_types(Absinthe.Type.Custom)
  import_types(NabooGraphQL.Application.Types)

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
  end

  # Even if having an empty mutation block is valid and works in Ansinthe, it
  # causes a Javascript error in GraphiQL so uncomment it when you add the
  # first mutation.
  #
  # mutation do
  # end

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
