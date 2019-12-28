defmodule Auth0Plug do
  @moduledoc """
  Documentation for Auth0Plug.
  """
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  @realm Application.get_env(:auth0_plug, :realm)
  @secret Application.get_env(:auth0_plug, :secret)
  @conn_key Application.get_env(:auth0_plug, :conn_key)

  def init(options) do
    options
  end

  @doc """
  Extracts the jwt from the header, when present.
  """
  def get_jwt(conn) do
    conn
    |> Conn.get_req_header("authorization")
    |> List.first()
  end

  def verify(token) do
    result =
      @secret
      |> JWK.from_oct()
      |> JWT.verify(token)

    case result do
      {true, jwt, _jws} -> {:ok, jwt}
      {false, jwt, _jws} -> {:error, jwt}
      {:error, e} -> {:error, e}
    end
  end

  @doc """
  Return a 401 response.
  """
  def unauthorized(conn) do
    conn
    |> Conn.put_resp_header(
      "www-authenticate",
      "Bearer realm=\"#{@realm}\", error=\"invalid_token\""
    )
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(401, Jason.encode!(%{}))
    |> Conn.halt()
  end

  def call(conn, _options) do
    token = Auth0Plug.get_jwt(conn)

    case Auth0Plug.verify(token) do
      {:ok, jwt} -> Conn.put_private(conn, @conn_key, jwt)
      {:error, _jwt} -> Auth0Plug.unauthorized(conn)
    end
  end
end
