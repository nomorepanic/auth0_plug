defmodule Auth0Plug.Jwt do
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  @conn_key Application.get_env(:auth0_plug, :conn_key)

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

  def put(conn, jwt) do
    key_to_extract = Application.get_env(:auth0_plug, :key_to_extract)
    value = Map.get(jwt, :fields)

    value =
      if key_to_extract do
        Map.get(value, key_to_extract)
      else
        value
      end

    Conn.put_private(conn, @conn_key, value)
  end
end
