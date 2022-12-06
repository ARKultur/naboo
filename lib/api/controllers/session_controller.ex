defmodule NabooAPI.SessionController do
  use Phoenix.Controller
  use PhoenixSwagger

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias Naboo.Cache
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
        |> Email.send()

        Cache.put(:totp_cache, two_factor_token, account.id)

        conn
        |> put_session("totp", %{"2fa" => two_factor_token, "id" => account.id})
        |> render("2fa.json", %{})
      else
        {:ok, token, _} = Sessions.log_in(conn, account)
        render(conn, "token.json", token: token)
      end
    rescue
      # probably uncool to do that, but whatever
      _err ->
        unauthorized(conn)
    end
  end

  def sign_in(conn, _params), do: unauthorized(conn)

  swagger_path(:email_2fa) do
    post("/validate_2fa")
    summary("Submit 2FA code")
    description("Confirm 2FA code")
    produces("application/json")
    deprecated(false)
    parameter(:code_2fa, :body, :string, "2FA code", required: true)

    response(200, "token.json", %{},
      example: %{
        token: "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
      }
    )
  end

  def email_2fa(conn, %{"code_2fa" => submitted_totp}) do
    with acc_id = Cache.get(:totp_cache, submitted_totp),
         true <- acc_id != nil,
         account = %Account{} <- Accounts.get_account(acc_id),
         {:ok, token, _} <- Sessions.log_in(conn, account) do
      conn
      |> delete_session("totp")
      |> render("token.json", token: token)
    else
      _ ->
        Cache.del(:totp_cache, submitted_totp)

        conn
        |> unauthorized()
    end
  end

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
