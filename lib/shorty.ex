defmodule Shorty do
  use GenServer

  # --- API ---

  def start_server(initial_state \\ nil) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  def get_state(pid) do
    GenServer.call(pid, {:get_state})
  end

  def shorten(pid, url) do
    GenServer.call(pid, {:shorten, url})
  end

  # --- Server ---

  def init(nil), do: {:ok, new_state()}
  def init(initial_state), do: {:ok, initial_state}

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:shorten, url}, _from, state) do
    url_id = Enum.count(state[:urls_by_id]) + 1
    state = put_in(state, [:urls_by_id, url_id], url)
    {:reply, url_id, state}
  end

  # --- Util ---

  def new_state() do
    %{urls_by_id: %{},
      # urls: %{},
      # urls_by_hostname: %{}
    }
  end
end
