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

  test "gets a URL from its shortened id" do
    {:ok, pid} = Shorty.start_server()
    url1 = "https://example.com/foo"
    Shorty.shorten(pid, url1)
    url2 = "https://example.com/bar"
    Shorty.shorten(pid, url2)
    assert url1 = Shorty.get(pid, 1)
    assert url2 = Shorty.get(pid, 2)
  end

  test "flush empties all state" do
    empty_state = %{urls_by_id: %{}}
    initial_state = %{urls_by_id:
                      %{1 => "https://example.com/foo",
                        2 => "https://example.com/bar"}}

    {:ok, pid} = Shorty.start_server(initial_state)
    assert ^initial_state = Shorty.get_state(pid)
    assert ^empty_state = Shorty.flush(pid)
    assert ^empty_state = Shorty.get_state(pid)
  end

  test "counts number of urls (not unique)" do
    {:ok, pid} = Shorty.start_server()
    Shorty.shorten(pid, "https://example.com/foo")
    assert 1 = Shorty.count(pid)
    Shorty.shorten(pid, "https://example.com/bar")
    assert 2 = Shorty.count(pid)
  end
end
