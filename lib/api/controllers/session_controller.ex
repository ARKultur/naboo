defmodule NabooAPI.SessionController do
  use Phoenix.Controller
  use PhoenixSwagger

  alias Naboo.Accounts
  alias NabooAPI.Auth.Sessions
  alias NabooAPI.Views.Errors

  require Logger

  swagger_path(:sign_in) do
    get("/account")
    summary("Log in")
    description("Log in with an account known in the database")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          email: "yolo",
          password: "amogus"
          },
        ]
      }
    )
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    with account <- Accounts.get_account_by_email(email),
         {:ok, _} <- Sessions.authenticate(account, password),
         {:ok, token, _} <- Sessions.log_in(conn, account) do
      render(conn, "token.json", token: token)
    else
      _ ->
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

  swagger_path(:unauthorized) do
    get("/account")
    summary("Refuses a connection")
    description("Refuses the connection if the arguments are wrong")
    produces("application/json")
    deprecated(false)

    response(200, "OK", Schema.ref(),
      example: %{
        data: [
        %{
          },
        ]
      }
    )
  end

  defp unauthorized(conn) do
    conn
    |> put_view(Errors)
    |> put_status(:unauthorized)
    |> render("401.json", [])
  end
end
