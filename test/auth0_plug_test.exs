defmodule Auth0PlugTest do
  use ExUnit.Case
  doctest Auth0Plug

  test "init/1" do
    assert Auth0Plug.init(:options) == :options
  end

  test "call/2" do
    assert Auth0Plug.call(:conn, :options) == :conn
  end
end
