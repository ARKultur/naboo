defmodule NabooWeb.AccountView do
  use Phoenix.View, root: "lib/naboo_web", path: "home/templates", namespace: NabooWeb
  alias NabooWeb.AccountView

  def render("token.json", token: token) do
    %{
      jwt: token
    }
  end

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      encrypted_password: account.encrypted_password,
      is_admin: account.is_admin
    }
  end
end
