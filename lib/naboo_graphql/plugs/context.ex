defmodule NabooGraphQL.Plugs.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      # returning the reason here could trigger an XSS
      {:error, _reason} ->
        conn
        |> send_resp(403, "Unauthorized >:(")
        |> halt()
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> auth_token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- authorize(auth_token) do
      {:ok, %{user_id: user_id}}
    else
      [] -> {:ok, %{}}
      error -> error
    end
  end

  def authorize(auth_token) do
    case Naboo.Accounts.find_by_auth_token!(auth_token: auth_token) do
      nil -> {:error, "Invalid authorization token"}
      user -> {:ok, user.id}
    end
  end
end
