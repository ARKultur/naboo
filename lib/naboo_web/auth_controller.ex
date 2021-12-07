defmodule NabooWeb.AuthController do
  use Phoenix.Controller

  alias Naboo.Accounts
  alias Naboo.Authentication
  alias Plug.Conn

  def create(conn, %{"account" => account_params}) do
    case Accounts.register(account_params) do
      {:ok, _account} ->
        Conn.send_resp(conn, 200, "Created account.")

      _ ->
        Conn.send_resp(conn, 500, "Wrong parameters, prolly. also fuck you")
    end
  end

  def delete(conn, _params) do
    conn
    |> Authentication.log_out()
    |> send_resp(200, "Disconnected.")
  end

  def new(conn, %{"account" => %{"email" => email, "password" => password}}) do
    case email
         |> Accounts.find_by_email!()
         |> Authentication.authenticate(password) do
      {:ok, account} ->
        conn
        |> Authentication.log_in(account)
        |> send_resp(200, "Connected.")

      {:error, _} ->
        Conn.send_resp(conn, 404, "Could not find user.")
    end
  end

  def index(conn, _params) do
    if Authentication.get_current_account(conn) do
      send_resp(conn, 200, "Connected.")
    else
      send_resp(conn, 201, "Not connected.")
    end
  end
end
