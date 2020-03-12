defmodule Auth0Plug.Jwt do
  alias Auth0Plug.Jwt
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  @doc """
  Extracts the jwt from the header, when present.
  """
  def get(conn) do
    conn
    |> Conn.get_req_header("authorization")
    |> List.to_string()
    |> String.split(" ")
    |> List.last()
  end

  def verify(_token, nil), do: {:error, nil}

  def verify(token, secret) do
    result =
      secret
      |> JWK.from_oct()
      |> JWT.verify(token)

    case result do
      {true, jwt, _jws} -> {:ok, jwt}
      {false, jwt, _jws} -> {:error, jwt}
      {:error, e} -> {:error, e}
    end
  end

  def put_extraction(conn, jwt, {key, conn_key}) do
    if key == nil do
      Conn.put_private(conn, conn_key, jwt)
    else
      Conn.put_private(conn, conn_key, Map.get(jwt, key))
    end
  end

  def put(conn, %{fields: jwt}) do
    :auth0_plug
    |> Application.get_env(:extractions)
    |> Enum.reduce(conn, fn extraction, acc ->
      Jwt.put_extraction(acc, jwt, extraction)
    end)
  end
end
