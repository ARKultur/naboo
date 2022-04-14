defmodule Naboo.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :naboo,
    module: Naboo.Auth.Guardian,
    error_handler: Naboo.Auth.Errors

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
end
