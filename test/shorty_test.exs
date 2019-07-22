defmodule ShortyTest do
  use ExUnit.Case
  doctest Shorty

  test "starts a server with no state" do
    assert {:ok, _pid} = Shorty.start_server()
  end

  test "starts a server with state" do
    initial_state = %{sample: "data"}
    assert {:ok, pid} = Shorty.start_server(initial_state)
    assert initial_state = Shorty.get_state(pid)
  end
end
