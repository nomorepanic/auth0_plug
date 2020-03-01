defmodule Auth0PlugTest do
  use ExUnit.Case
  import Dummy

  alias Auth0Plug.Jwt
  alias Plug.Conn

  doctest Auth0Plug

  test "init/1" do
    assert Auth0Plug.init(:options) == :options
  end

  test "unauthorzied_message/1" do
    default = "Your credentials are invalid."

    dummy Application, [{"get_env", fn _a, _b, _c -> "message" end}] do
      dummy Jason, [{"encode!", :json}] do
        assert Auth0Plug.unauthorized_message() == :json

        assert called(
                 Application.get_env(
                   :auth0_plug,
                   :unauthorized_message,
                   default
                 )
               )

        assert called(Jason.encode!(%{"message" => "message"}))
      end
    end
  end

  test "is_excluded?/1" do
    conn = %{private: %{plug_route: {"/"}}}

    dummy Application, [{"get_env", fn _a, _b -> ["path"] end}] do
      assert Auth0Plug.is_excluded?(conn) == false
      assert called(Application.get_env(:auth0_plug, :exclude_from_401))
    end
  end

  test "is_excluded?/1, true" do
    conn = %{private: %{plug_route: {"path"}}}

    dummy Application, [{"get_env", fn _a, _b -> ["path"] end}] do
      assert Auth0Plug.is_excluded?(conn) == true
    end
  end

  test "is_401?/1" do
    dummy Application, [{"get_env", fn _a, _b -> true end}] do
      dummy Auth0Plug, [{"is_excluded?", false}] do
        assert Auth0Plug.is_401?(:conn) == true
        assert called(Application.get_env(:auth0_plug, :return_401))
        assert called(Auth0Plug.is_excluded?(:conn))
      end
    end
  end

  test "is_401?/1, excluded" do
    dummy Application, [{"get_env", fn _a, _b -> true end}] do
      dummy Auth0Plug, [{"is_excluded?", true}] do
        assert Auth0Plug.is_401?(:conn) == false
      end
    end
  end

  test "is_401?/1, false" do
    dummy Application, [{"get_env", fn _a, _b -> false end}] do
      assert Auth0Plug.is_401?(:conn) == false
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
      dummy Auth0Plug, [
        {"is_401?", true},
        {"unauthorized_message", fn -> :message end}
      ] do
        assert Auth0Plug.unauthorized(:conn) == :halt
        assert called(Auth0Plug.is_401?(:conn))
        assert called(Conn.put_resp_header(:conn, header_name, auth_header))
        assert called(Conn.put_resp_content_type(:header, "application/json"))
        assert called(Auth0Plug.unauthorized_message())
        assert called(Conn.send_resp(:content_type, 401, :message))
      end
    end
  end

  test "unauthorized/1, not 401" do
    dummy Auth0Plug, [{"is_401?", false}] do
      assert Auth0Plug.unauthorized(:conn) == :conn
    end
  end

  test "call/2" do
    dummy Jwt, [
      {"get", :token},
      {"verify", fn _a, _b -> {:ok, :jwt} end},
      {"put", fn _a, _b -> :conn end}
    ] do
      assert Auth0Plug.call(:conn, :options) == :conn
      assert called(Jwt.get(:conn))
      assert called(Jwt.put(:conn, :jwt))
    end
  end

  test "call/2, unauthorized" do
    dummy Jwt, [
      {"get", :token},
      {"verify", fn _a, _b -> {:error, :jwt} end}
    ] do
      dummy Auth0Plug, [
        {"unauthorized", :unauthorized}
      ] do
        assert Auth0Plug.call(:conn, :options) == :unauthorized
        assert called(Auth0Plug.unauthorized(:conn))
      end
    end
  end
end
