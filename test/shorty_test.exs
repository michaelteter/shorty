defmodule ShortyTest do
  use ExUnit.Case
  doctest Shorty

  test "starts a server with no state" do
    assert {:ok, _pid} = Shorty.start_server()
  end
end
