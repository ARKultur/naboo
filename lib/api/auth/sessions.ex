defmodule NabooAPI.Auth.Sessions do
  use Guardian, otp_app: :naboo

  alias Naboo.Accounts
  alias Naboo.Accounts.Account
  alias NabooAPI.Auth.Guardian

  require Logger

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_account(id) do
      nil -> {:error, :resource_not_found}
      account -> {:ok, account}
    end
  end

  def log_out(conn) do
    __MODULE__.Plug.sign_out(conn)
  end

  def resource(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def log_in(conn, account) do
    with conn <- __MODULE__.Plug.sign_in(conn, account),
         {:ok, token, _claims} <- Guardian.encode_and_sign(account, token_type: "access", ttl: {1, :day}) do
      {:ok, token, conn}
    else
      _err -> {:ko, :unauthorized}
    end
  end

  def authenticate(%Account{} = account, pw) do
    authenticate(account, pw, Argon2.verify_pass(pw, account.encrypted_password))
  end

  def authenticate(nil, password), do: authenticate(nil, password, Argon2.no_user_verify())
  defp authenticate(account, _password, true), do: {:ok, account}

  defp authenticate(_account, _password, false) do
    {:error, :invalid_credentials}
  end
end
