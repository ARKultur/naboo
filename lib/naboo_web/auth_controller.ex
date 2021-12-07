defmodule NabooWeb.AuthController do
  use Phoenix.Controller

  require Logger

  alias Naboo.Accounts
  alias Naboo.Authentication

  alias Naboo.Json

  def create(conn, %{"account" => account_params}) do
    case Accounts.register(account_params) do
      {:ok, _account} ->
        conn
        |> Json.send_json(200, "Created account.")

      _ ->
        Json.send_json(conn, 500, "Wrong parameters, prolly. also fuck you")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> Json.send_json(200, "Disconnected.")
  end

  def new(conn, %{"email" => email, "password" => password}) do

    Logger.info "Attempting to log #{email}"

    case email
         |> Accounts.find_by_email!()
         |> Authentication.authenticate(password) do
      {:ok, account} ->
        conn
        |> Authentication.log_in(account)
        |> Json.send_json(200, account)

      {:error, _} ->
        Json.send_json(conn, 400, "Could not find user.")
    end
  end

  def index(conn, _params) do
    if Authentication.get_current_account(conn) do
      Json.send_json(conn, 200, :connected)
    else
      Json.send_json(conn, 200, :not_connected)
    end
  end
end
