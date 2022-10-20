defmodule NabooAPI.Auth.Guardian.IsAdminPipeline do
  import Plug.Conn
  import Plug.Controller

  alias NabooAPI.Auth.Guardian
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Views.Errors
  alias Naboo.Accounts.Account

  def init(opts), do: opts

  def call(conn, _params) do
    case Sessions.resource(conn) do

      %Account{} = account ->
        if account.is_admin do
          conn
        else
          conn
          |> put_view(Errors)
          |> put_status(:forbidden)
          |> render("error_messages.json", %{errors: "This account is not an admin"})
        end

      _ ->
        conn
        |> put_view(Errors)
        |> put_status(:forbidden)
        |> render("error_messages.json", %{errors: "Please login"})
    end
  end
end
