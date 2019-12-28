defmodule Auth0PlugTest do
  use ExUnit.Case
  import Dummy

  alias JOSE.{JWK, JWT}
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

  test "verify/1" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {true, :jwt, :jws} end}] do
        assert Auth0Plug.verify(:token) == {:ok, :jwt}
        assert called(JWK.from_oct("secret"))
        assert called(JWT.verify(:oct, :token))
      end
    end
  end

  test "verify/1, invalid jwt" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {:error, :e} end}] do
        assert Auth0Plug.verify(:token) == {:error, :e}
      end
    end
  end

  test "verify/1, error" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {false, :jwt, :jws} end}] do
        assert Auth0Plug.verify(:token) == {:error, :jwt}
      end
    end
  end

  test "call/2" do
    assert Auth0Plug.call(:conn, :options) == :conn
  end
end
