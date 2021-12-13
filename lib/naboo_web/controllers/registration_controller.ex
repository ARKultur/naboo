defmodule NabooWeb.RegistrationController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Authentication
  alias NabooWeb.Router.Helpers

  def new(conn, _) do
    if Authentication.get_current_account(conn) do
      redirect(conn, to: Helpers.account_path(conn, :show))
    else
      render(conn, :new,
        changeset: Accounts.change_account(),
        action: Helpers.account_path(conn, :create)
      )
    end
  end
end
