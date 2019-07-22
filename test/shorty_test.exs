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

  test "shortens a URL" do
    {:ok, pid} = Shorty.start_server()
    url1 = "https://example.com/foo"
    assert 1 = Shorty.shorten(pid, url1)
    url2 = "https://example.com/bar"
    assert 2 = Shorty.shorten(pid, url2)
    assert %{urls_by_id: %{1 => url1,
                           2 => url2}} == Shorty.get_state(pid)
  end
end
