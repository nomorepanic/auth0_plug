defmodule Auth0Plug do
  @moduledoc """
  Documentation for Auth0Plug.
  """
  alias Auth0Plug.Jwt
  alias Plug.Conn

  @realm Application.compile_env(:auth0_plug, :realm)
  @secret Application.compile_env(:auth0_plug, :secret)

  if @secret == nil do
    "Auth0Plug's secret is set to nil. Authentication will always fail."
    |> IO.warn()
  end

  def init(options) do
    options
  end

  def unauthorized_message do
    default = "Your credentials are invalid."
    message = Application.get_env(:auth0_plug, :unauthorized_message, default)
    Jason.encode!(%{"message" => message})
  end

  @doc """
  Whether the path is excluded.
  """
  def is_excluded?(conn) do
    Application.get_env(:auth0_plug, :exclude_from_401)
    |> List.insert_at(0, "/*_path")
    |> Enum.member?(elem(conn.private[:plug_route], 0))
  end

  @doc """
  Whether a 401 should be returned.

  401s are return only when return_401 is set to true and the path is not in
  exclude_from_401.
  """
  def is_401?(conn) do
    if Application.get_env(:auth0_plug, :return_401) do
      if Auth0Plug.is_excluded?(conn) do
        false
      else
        true
      end
    else
      false
    end
  end

  @doc """
  Sends a 401.

  This is a separate function so that it can be reused to send the same 401
  when is not directly sent by Auth0Plug, for example to send a 401 on an
  ignored route.
  """
  def send_401(conn) do
    conn
    |> Conn.put_resp_header(
      "www-authenticate",
      "Bearer realm=\"#{@realm}\", error=\"invalid_token\""
    )
    |> Conn.put_resp_content_type("application/json")
    |> Conn.send_resp(401, Auth0Plug.unauthorized_message())
  end

  @doc """
  Return a 401 response.
  """
  def unauthorized(conn) do
    if Auth0Plug.is_401?(conn) do
      conn
      |> Auth0Plug.send_401()
      |> Conn.halt()
    else
      conn
    end
  end

  def call(conn, _options) do
    token = Jwt.get(conn)

    case Jwt.verify(token, @secret) do
      {:ok, jwt} -> Jwt.put(conn, jwt)
      {:error, _jwt} -> Auth0Plug.unauthorized(conn)
    end
  end

  @doc """
  Exposes Jwt.get/1
  """
  def get_jwt(conn), do: Jwt.get(conn)
end
