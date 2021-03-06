defmodule NabooAPI.Auth.Guardian.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :naboo,
    module: NabooAPI.Auth.Guardian,
    error_handler: NabooAPI.Auth.Errors

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
end
