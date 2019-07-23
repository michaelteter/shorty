defmodule Shorty do
  @moduledoc """
  GenServer module that provides URL shortening services.
  """

  use GenServer

  # --- API ---

  def start_server(initial_state \\ nil) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  @doc false
  def get_state(pid), do: GenServer.call(pid, {:get_state})

  @doc """
  Shorten a url to a unique ID.
  """
  def shorten(pid, url), do: GenServer.call(pid, {:shorten, url})

  @doc """
  Get original URL from its unique ID.
  """
  def get(pid, url_id), do: GenServer.call(pid, {:get, url_id})

  @doc """
  Clear all history of shortened URLs and related statistics.
  """
  def flush(pid), do: GenServer.call(pid, {:flush})

  @doc """
  Get the total count of all shortened URLs.
  Note that the same URL shortened twice will be counted twice
  because it has two IDs associated with it.  This allows for
  fine grained tracking of shortened URL use.
  """
  def count(pid), do: GenServer.call(pid, {:count})

  @doc """
  Get hostnames of all URLs with a count of their associated URLs.
  """
  def get_stats(pid), do: GenServer.call(pid, {:get_stats})

  @doc """
  Get the number of times each shortened URL has been retrieved (clicked).
  """
  def get_click_stats(pid), do: GenServer.call(pid, {:get_click_stats})

  @doc """
  Get the number of times a specific shortened URL has been retrieved (clicked).
  """
  def get_click_stats(pid, url_id), do: GenServer.call(pid, {:get_click_stats, url_id})

  # --- Server ---

  @doc false
  def init(nil), do: {:ok, empty_state()}

  @doc false
  def init(initial_state), do: {:ok, initial_state}

  @doc false
  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  @doc false
  def handle_call({:shorten, url}, _from, state) do
    url_id = Enum.count(state[:urls_by_id]) + 1
    state = put_in(state, 
                   [:urls_by_id, url_id], 
                   %{url: url, clicks: 0})

    hostname = Shorty.hostname_from_url(url)
    state = Map.replace!(state,
                         :urls_by_hostname,
                         Map.update(state[:urls_by_hostname],
                                    hostname,
                                    [url_id],
                                    &([url_id | &1])))

    {:reply, url_id, state}
  end

  @doc false
  def handle_call({:get, url_id}, _from, state) do
    url = Shorty.url_from_id(url_id, state)
    state = case url do
      nil -> state
      _ -> Shorty.inc_click_count(url_id, state)
    end
    {:reply, url, state}
  end

  @doc false
  def handle_call({:flush}, _from, _state) do 
    {:reply, empty_state(), empty_state()}
  end

  @doc false
  def handle_call({:count}, _from, state) do
    {:reply, Shorty.count_urls(state), state}
  end

  def handle_call({:get_stats}, _from, state) do
    counts = Enum.into(state[:urls_by_hostname],
                       %{},
                       fn {k, v} -> {k, Enum.count(v)} end)

    {:reply, counts, state}
  end

  def handle_call({:get_click_stats, url_id}, _from, state) do
    clicks = state[:urls_by_id][url_id][:clicks]
    {:reply, clicks, state}
  end

  def handle_call({:get_click_stats}, _from, state) do
    clicks = Enum.into(state[:urls_by_id],
                       %{},
                       fn {k, v} -> {k, v[:clicks]} end)
    {:reply, clicks, state}
  end

  # --- Util ---

  @doc false
  def empty_state() do
    %{urls_by_id: %{},
      urls_by_hostname: %{}}
  end

  @doc false
  def url_from_id(url_id, state) do
    state[:urls_by_id][url_id][:url]
  end

  @doc false
  def count_urls(state) do
    Enum.count(state[:urls_by_id])
  end

  @doc false
  def inc_click_count(url_id, state) do
    update_in(state, [:urls_by_id, url_id, :clicks], &(&1 + 1))
  end

  @doc """
  Determine the hostname of a URL.
  """
  def hostname_from_url(url) do
    Regex.scan(~r/^.*\/\/([^\/:]*)/, url)
    |> List.flatten()
    |> List.last()
  end
end
