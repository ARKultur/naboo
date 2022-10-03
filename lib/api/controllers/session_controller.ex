defmodule NabooAPI.SessionController do
  use Phoenix.Controller
  use PhoenixSwagger

  alias Naboo.Accounts
  alias NabooAPI.Auth.Sessions
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
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
      }
    )
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Sessions.authenticate(account, password),
         {:ok, token, _} <- Sessions.log_in(conn, account) do
      render(conn, "token.json", token: token)
    else
      {:error, something} ->
        conn
        |> put_view(Errors)
        |> put_status(:unauthorized)
        |> render("error_messages.json", %{errors: something})

      _err ->
        unauthorized(conn)
    end
  end

  def sign_in(conn, _params), do: unauthorized(conn)

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
