defmodule NabooAPI.Email do
  use Bamboo.Mailer, otp_app: :naboo
  import Bamboo.Email

  require Logger

  def base_link(), do: System.fetch_env!("CANONICAL_URL")

  def send_2fa(name, email, code) do
    body = "Hello #{name} ! Your 2FA code is <b>#{code}</b>."

    send_email_with_body(email, "Two-factor authentication", body)
  end

  def welcome_email(name, email, confirm_link) do
    body =
      "Thanks for joining #{name}!" <>
        " Please click " <>
        "<a href=\"#{confirm_link}\">here</a>" <>
        " to confirm your account !"

    send_email_with_body(email, "Confirm your account", body)
  end

  def password_reset(name, email, reset_id) do
    link = base_link() <> "/password-reset/" <> to_string(reset_id) <> "/edit"
    body = "Hello #{name}. " <> "Please click " <> "<a href=\"#{link}\">here</a>" <> " to reset your password."

    send_email_with_body(email, "Reset password", body)
  end

  def send_email_with_body(email, subject, body) do
    Logger.info("Sending [#{subject}]:[#{body}] -> #{email}")

    new_email(to: email, from: System.fetch_env!("SENDGRID_SENDER_EMAIL"), subject: "Naboo ~ " <> subject, html_body: body)
  end
end
