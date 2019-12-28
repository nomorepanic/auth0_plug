defmodule Auth0Plug do
  @moduledoc """
  Documentation for Auth0Plug.
  """
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  @secret Application.get_env(:auth0_plug, :secret)

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

  def call(conn, _options) do
    conn
  end
end
