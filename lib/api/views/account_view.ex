defmodule NabooAPI.AccountView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.AccountView

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
      is_admin: account.is_admin
    }
  end

  def render("already_exists.json", %{email: email}) do
    %{
      message: "account already exists",
      email: email
    }
  end
end
