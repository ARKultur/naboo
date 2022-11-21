defmodule NabooAPI.AccountView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.{AccountView, NodeView}

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("index_preloaded.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "preloaded.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("show_preload.json", %{account: account}) do
    %{
      data: render_one(account, AccountView, "preloaded.json")
    }
  end

  def render("preloaded.json", %{account: account}) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      is_admin: account.is_admin,
      has_2fa: account.has_2fa,
      domains: render_many(account.domains, NodeView, "node.json")
    }
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      has_2fa: account.has_2fa,
      is_admin: account.is_admin
    }
  end

  def render("already_exists.json", _) do
    %{
      message: "account already exists"
    }
  end
end
