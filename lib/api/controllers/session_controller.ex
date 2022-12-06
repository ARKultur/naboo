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

      cond do
        not account.has_confirmed ->
          conn
          |> put_status(:unauthorized)
          |> put_view(Errors)
          |> render("error_messages.json", %{errors: "please confirm your account !"})

        account.has_2fa ->
          two_factor_token = TwoFactor.gen_token()

          Email.send_2fa(account.name, account.email, two_factor_token)
          |> Email.send()

          Cache.put(:totp_cache, two_factor_token, account.id)

          conn
          |> render("2fa.json", %{})

        true ->
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
      Cache.del(:totp_cache, submitted_totp)

      conn
      |> render("token.json", token: token)
    else
      _ ->
        Cache.del(:totp_cache, submitted_totp)

        conn
        |> unauthorized()
    end
  end

  swagger_path(:confirm_account) do
    post("/confirm_account")
    summary("Submit account-confirmation token")
    description("Confirm account")
    produces("application/json")
    deprecated(false)
    parameter(:confirm_token, :body, :string, "Confirmation code", required: true)

    response(200, "token.json", %{},
      example: %{
        token: "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
      }
    )
  end

  def confirm_account(conn, %{"confirm_token" => token}) do
    with acc_id = Cache.get(:cf_token_cache, token),
         true <- acc_id != nil,
         account = %Account{} <- Accounts.get_account(acc_id),
         {:ok, updated} <- Accounts.update_account(account, %{has_confirmed: true}),
         {:ok, jwt, _} <- Sessions.log_in(conn, updated) do
      Cache.del(:cf_token_cache, token)

      conn
      |> render("token.json", token: jwt)
    else
      _err ->
        Cache.del(:cf_token_cache, token)
        unauthorized(conn)
    end
  end

  swagger_path(:new_confirm_token) do
    post("/confirm_account/new")
    summary("Request new account-confirmation token")
    description("Request new account token")
    produces("application/json")
    deprecated(false)
    parameter(:email, :body, :string, "account email", required: true)

    response(200, "token.json", %{},
      example: %{
        id: 1,
        message: "a new code has been sent"
      }
    )
  end

  def new_confirm_token(conn, %{"email" => email}) do
    with account = %Account{} <- Accounts.get_account_by_email(email) do
      cond do
        account.has_confirmed ->
          conn
          |> put_view(Errors)
          |> put_status(:bad_request)
          |> render("error_messages.json", errors: "account has already been confirmed")

        true ->
          new_token = TwoFactor.gen_token()
          Cache.put(:cf_token_cache, account.id, new_token, 1_000_000)

          {:ok, _value} =
            Email.welcome_email(account.name, account.email, new_token)
            |> Email.send()

          conn
          |> put_status(:ok)
          |> render("resent.json", account: account)
      end
    else
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(Errors)
        |> render("error_messages.json", errors: "could not find account")
    end
  end

  swagger_path(:delete) do
    post("/logout")
    summary("Log out account")
    description("Will simply destroy JWT token")
    produces("application/json")
    deprecated(false)

    response(200, "disconnected.json", %{},
      example: %{
        message: "successfully disconnected"
      }
    )
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
