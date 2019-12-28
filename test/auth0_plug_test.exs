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

  test "unauthorized/1" do
    auth_header = "Bearer realm=\"realm\", error=\"invalid_token\""
    header_name = "www-authenticate"

    dummy Conn, [
      {"put_resp_header", fn _a, _b, _c -> :header end},
      {"put_resp_content_type", fn _a, _b -> :content_type end},
      {"send_resp", fn _a, _b, _c -> :resp end},
      {"halt", :halt}
    ] do
      assert Auth0Plug.unauthorized(:conn) == :halt
      assert called(Conn.put_resp_header(:conn, header_name, auth_header))
      assert called(Conn.put_resp_content_type(:header, "application/json"))
      assert called(Conn.send_resp(:content_type, 401, "{}"))
    end
  end

  test "call/2" do
    dummy Conn, [{"put_private", fn _a, _b, _c -> :conn end}] do
      dummy Auth0Plug, [{"get_jwt", :token}, {"verify", {:ok, :jwt}}] do
        assert Auth0Plug.call(:conn, :options) == :conn
        assert called(Auth0Plug.get_jwt(:conn))
        assert called(Conn.put_private(:conn, :auth0_plug_jwt, :jwt))
      end
    end
  end

  test "call/2, unauthorized" do
    dummy Auth0Plug, [
      {"get_jwt", :token},
      {"verify", {:error, :jwt}},
      {"unauthorized", :unauthorized}
    ] do
      assert Auth0Plug.call(:conn, :options) == :unauthorized
      assert called(Auth0Plug.unauthorized(:conn))
    end
  end
end
