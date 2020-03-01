defmodule Auth0PlugTest.Jwt do
  use ExUnit.Case
  import Dummy

  alias Auth0Plug.Jwt
  alias JOSE.{JWK, JWT}
  alias Plug.Conn

  test "get/1" do
    dummy Conn, [{"get_req_header", fn _a, _b -> ["bearer token"] end}] do
      assert Jwt.get(:conn) == "token"
    end
  end

  test "get/1 with an empty list" do
    dummy Conn, [{"get_req_header", fn _a, _b -> [] end}] do
      assert Jwt.get(:conn) == ""
    end
  end

  test "verify/2" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {true, :jwt, :jws} end}] do
        assert Jwt.verify(:token, :secret) == {:ok, :jwt}
        assert called(JWK.from_oct(:secret))
        assert called(JWT.verify(:oct, :token))
      end
    end
  end

  test "verify/2, invalid jwt" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {:error, :e} end}] do
        assert Jwt.verify(:token, :secret) == {:error, :e}
      end
    end
  end

  test "verify/2, error" do
    dummy JWK, [{"from_oct", :oct}] do
      dummy JWT, [{"verify", fn _a, _b -> {false, :jwt, :jws} end}] do
        assert Jwt.verify(:token, :secret) == {:error, :jwt}
      end
    end
  end

  test "verify/2, null secret" do
    assert Jwt.verify(:token, nil) == {:error, nil}
  end

  test "put/2" do
    dummy Application, [{"get_env", fn _a, _b -> nil end}] do
      dummy Conn, [{"put_private", fn _a, _b, _c -> :conn end}] do
        Jwt.put(:conn, %{fields: :fields})
        assert called(Application.get_env(:auth0_plug, :key_to_extract))
        assert called(Conn.put_private(:conn, :auth0_plug_jwt, :fields))
      end
    end
  end
end
