defmodule Auth0PlugTest do
  use ExUnit.Case
  alias Plug.Conn

  doctest Auth0Plug

  test "init/1" do
    assert Auth0Plug.init(:options) == :options
  end

  test "get_jwt/1" do
    dummy Conn, [{"get_req_header", fn _a, _b -> [:header] end}] do
      assert Auth0Plug.get_jwt(:conn) == :header
    end
  end

  test "get_jwt/1 with an empty list" do
    dummy Conn, [{"get_req_header", fn _a, _b -> [] end}] do
      assert Auth0Plug.get_jwt(:conn) == nil
    end
  end

  test "call/2" do
    assert Auth0Plug.call(:conn, :options) == :conn
  end
end
