defmodule Auth0Plug do
  @moduledoc """
  Documentation for Auth0Plug.
  """
  alias Plug.Conn

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

  def call(conn, _options) do
    conn
  end
end
