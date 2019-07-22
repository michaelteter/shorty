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
    url3 = "https://anyother.com/day"
    assert 3 = Shorty.shorten(pid, url3)

    expected = %{urls_by_id: 
                   %{1 => %{clicks: 0, url: "https://example.com/foo"}, 
                     2 => %{clicks: 0, url: "https://example.com/bar"},
                     3 => %{clicks: 0, url: "https://anyother.com/day"}},
                 urls_by_hostname: 
                   %{"example.com" => [2, 1],
                     "anyother.com" => [3]}}
    assert ^expected = Shorty.get_state(pid)
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
    empty_state = %{urls_by_id: %{}, urls_by_hostname: %{}}
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

  test "extracts hostname from url" do
    assert "example.com" = Shorty.hostname_from_url("https://example.com")
    assert "example.com" = Shorty.hostname_from_url("http://example.com")
    assert "example.com" = Shorty.hostname_from_url("http://example.com:8080")
    assert "dev.example.com" = Shorty.hostname_from_url("http://dev.example.com:8080")
    assert "短.co" = Shorty.hostname_from_url("http://短.co")
  end

  test "gets stats: counts of urls by each hostname" do
    {:ok, pid} = Shorty.start_server()
    Shorty.shorten(pid, "https://example.com/foo")
    Shorty.shorten(pid, "https://example.com/bar")
    Shorty.shorten(pid, "https://another.com/one")
    Shorty.shorten(pid, "https://another.com/two")
    Shorty.shorten(pid, "https://somuch.com/host")
    
    expected = %{"example.com" => 2,
                 "another.com" => 2,
                 "somuch.com"  => 1}

    assert ^expected = Shorty.get_stats(pid)
  end
end
