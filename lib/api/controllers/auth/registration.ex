defmodule NabooAPI.Controllers.Auth.Registration do
  use Phoenix.Controller

  alias Naboo.Accounts.AccountManager
  alias Naboo.Auth.Sessions
  alias NabooAPI.Router.Urls.Helpers

  def new(conn, _) do
    if Sessions.get_current_account(conn) do
      redirect(conn, to: "/api/v1/account/:id")
    else
      render(conn, :new,
        changeset: AccountManager.change_account(),
        action: Helpers.account_path(conn, :create)
      )
    end
  end
end
