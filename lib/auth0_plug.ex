defmodule Auth0Plug do
  @moduledoc """
  Documentation for Auth0Plug.
  """
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  @conn_key Application.get_env(:auth0_plug, :conn_key)
  @key_to_extract Application.get_env(:auth0_plug, :key_to_extract)
  @realm Application.get_env(:auth0_plug, :realm)
  @secret Application.get_env(:auth0_plug, :secret)
  @return_401 Application.get_env(:auth0_plug, :return_401)

  def init(options) do
    options
  end

  def unauthorized_message do
    default = "Your credentials are invalid."
    message = Application.get_env(:auth0_plug, :unauthorized_message, default)
    Jason.encode!(%{"message" => message})
  end

  @doc """
  Extracts the jwt from the header, when present.
  """
  def get_jwt(conn) do
    conn
    |> Conn.get_req_header("authorization")
    |> List.to_string()
    |> String.split(" ")
    |> List.last()
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
    if @return_401 do
      conn
      |> Conn.put_resp_header(
        "www-authenticate",
        "Bearer realm=\"#{@realm}\", error=\"invalid_token\""
      )
      |> Conn.put_resp_content_type("application/json")
      |> Conn.send_resp(401, Jason.encode!(%{}))
      |> Conn.halt()
    else
      conn
    end
  end

  def put_jwt(conn, jwt) do
    value = Map.get(jwt, :fields)

    value =
      if @key_to_extract do
        Map.get(value, @key_to_extract)
      else
        value
      end

    Conn.put_private(conn, @conn_key, value)
  end

  def call(conn, _options) do
    token = Auth0Plug.get_jwt(conn)

    case Auth0Plug.verify(token) do
      {:ok, jwt} -> Auth0Plug.put_jwt(conn, jwt)
      {:error, _jwt} -> Auth0Plug.unauthorized(conn)
    end
  end
end
