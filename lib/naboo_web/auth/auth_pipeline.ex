defmodule NabooWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :naboo,
    module: NabooWeb.Guardian,
    error_handler: NabooWeb.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
end