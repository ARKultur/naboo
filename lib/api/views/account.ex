defmodule NabooAPI.Views.Account do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, Account, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, Account, "account.json")}
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
