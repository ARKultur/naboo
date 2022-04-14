defmodule Naboo.Auth.Guardian do
  use Guardian, otp_app: :naboo

  alias Naboo.Accounts

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    Accounts.Controller.get_account(id)
  end

  def subject_for_token(_), do: {:error, :unknown_parameters}
end
