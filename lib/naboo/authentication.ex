defmodule Naboo.Authentication do
  alias Naboo.Accounts.Account

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

  def generate_token() do
    length = 32

    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
