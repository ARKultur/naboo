defmodule NabooAPI.SessionController do
  use Phoenix.Controller
  use PhoenixSwagger

  alias Naboo.Accounts
  alias NabooAPI.Auth.TwoFactor
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Email
  alias NabooAPI.Views.Errors

  require Logger

  swagger_path(:sign_in) do
    post("/login")
    summary("Log in")
    description("Log in with an account known in the database")
    produces("application/json")
    deprecated(false)
    parameter(:email, :body, :string, "email of the account", required: true)
    parameter(:password, :body, :string, "password of the account", required: true)

    response(200, "token.json", %{},
      example: %{
        token: "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
      }
    )
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    try do
      account = Accounts.get_account_by_email(email)
      {:ok, _} = Sessions.authenticate(account, password)

      if account.has_2fa do
        two_factor_token = TwoFactor.gen_token()
        Email.send_2fa(account.name, account.email, two_factor_token)

      else
        {:ok, token, _} = Sessions.log_in(conn, account)
        render(conn, "token.json", token: token)
      end

    rescue
      # probably uncool to do that, but whatever
      _ ->
        unauthorized(conn)
    end
  end

  def sign_in(conn, _params), do: unauthorized(conn)

  def delete(conn, _params) do
    conn
    |> Sessions.log_out()
    |> put_status(:ok)
    |> render("disconnected.json", [])
  end

  defp unauthorized(conn) do
    conn
    |> put_view(Errors)
    |> put_status(:unauthorized)
    |> render("401.json", [])
  end
end
