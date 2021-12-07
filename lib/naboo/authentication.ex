defmodule Naboo.Authentication do
  use Guardian, otp_app: :naboo

  alias Naboo.Accounts
  alias Naboo.Accounts.Account

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

  def log_in(conn, account) do
    __MODULE__.Plug.sign_in(conn, account)
  end

  def get_current_account(conn) do
    __MODULE__.Plug.current_resource(conn)
  end

  def authenticate(%Account{} = account, password) do
    authenticate(
      account,
      password,
      Argon2.verify_pass(password, account.encrypted_password)
    )
  end

  def authenticate(nil, password) do
    authenticate(nil, password, Argon2.no_user_verify())
  end

  defp authenticate(account, _password, true) do
    {:ok, account}
  end

  defp authenticate(_account, _password, false) do
    {:error, :invalid_credentials}
  end

  def generate_token do
    length = 32
    bytes = :crypto.strong_rand_bytes(length)

    bytes
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
