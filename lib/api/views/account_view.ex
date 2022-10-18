defmodule NabooAPI.AccountView do
  use Phoenix.View, root: "lib/api", namespace: NabooAPI

  alias NabooAPI.{AccountView, NodeView}

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("show_preload.json", %{account: account}) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      is_admin: account.is_admin,
      nodes: render_many(account.nodes, NodeView, "index.json")
    }
  end

  def render("account.json", %{account: account}) do
    %{
      id: account.id,
      name: account.name,
      email: account.email,
      is_admin: account.is_admin
    }
  end

  def render("already_exists.json", _) do
    %{
      message: "account already exists"
    }
  end
end
