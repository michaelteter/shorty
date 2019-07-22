defmodule Shorty do
  use GenServer

  # --- API ---

  def start_server(initial_state \\ nil) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  def get_state(pid), do: GenServer.call(pid, {:get_state})

  def shorten(pid, url), do: GenServer.call(pid, {:shorten, url})

  def get(pid, url_id), do: GenServer.call(pid, {:get, url_id})

  def flush(pid), do: GenServer.call(pid, {:flush})

  def count(pid), do: GenServer.call(pid, {:count})

  def get_stats(pid), do: GenServer.call(pid, {:get_stats})

  # --- Server ---

  def init(nil), do: {:ok, empty_state()}
  def init(initial_state), do: {:ok, initial_state}

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:shorten, url}, _from, state) do
    url_id = Enum.count(state[:urls_by_id]) + 1
    state = put_in(state, [:urls_by_id, url_id], url)
    {:reply, url_id, state}
  end

  def handle_call({:get, url_id}, _from, state) do
    {:reply, Shorty.url_from_id(url_id, state), state}
  end

  def handle_call({:flush}, _from, _state) do 
    {:reply, empty_state(), empty_state()}
  end

  def handle_call({:count}, _from, state) do
    {:reply, Shorty.count_urls(state), state}
  end

  def handle_call({:get_stats}, _from, state) do
    {:reply, state, state}
  end

  # --- Util ---

  def empty_state() do
    %{urls_by_id: %{},
      # urls: %{},
      # urls_by_hostname: %{}
    }
  end

  def url_from_id(url_id, state) do
    state[:urls_by_id][url_id]
  end

  def count_urls(state) do
    Enum.count(state[:urls_by_id])
  end

  def hostname_from_url(url) do
    Regex.scan(~r/^.*\/\/([^\/:]*)/, url)
    |> List.flatten()
    |> List.last()
  end
end
