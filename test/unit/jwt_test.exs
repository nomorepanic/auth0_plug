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

  test "put_extraction/2" do
    jwt = %{"key" => "value"}

    dummy Conn, [{"put_private", fn _a, _b, _c -> :conn end}] do
      assert Jwt.put_extraction(:conn, jwt, {"key", :conn_key}) == :conn
      assert called(Conn.put_private(:conn, :conn_key, "value"))
    end
  end

  test "put_extraction/2 with nil" do
    jwt = %{"key" => "value"}

    dummy Conn, [{"put_private", fn _a, _b, _c -> :conn end}] do
      assert Jwt.put_extraction(:conn, jwt, {nil, :conn_key}) == :conn
      assert called(Conn.put_private(:conn, :conn_key, jwt))
    end
  end

  test "put/2" do
    jwt = %{"key" => "value"}

    dummy Application, [{"get_env", fn _a, _b -> [:extraction] end}] do
      dummy Jwt, [{"put_extraction", fn _a, _b, _c -> :extraction end}] do
        Jwt.put(:conn, %{fields: jwt})
        assert called(Application.get_env(:auth0_plug, :extractions))
        assert called(Jwt.put_extraction(:conn, jwt, :extraction))
      end
    end
  end

  test "put/2 with empty extractions" do
    dummy Application, [{"get_env", fn _a, _b -> [] end}] do
      assert Jwt.put(:conn, %{fields: :fields}) == :conn
    end
  end
end
