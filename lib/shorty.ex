defmodule Shorty do
  use GenServer

  # --- API ---

  def start_server(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  def get_state(pid) do
    GenServer.call(pid, {:get_state})
  end

  # --- Server ---

  def init(), do: {:ok, new_state()}
  def init(initial_state), do: {:ok, initial_state}

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  # --- Util ---

  def new_state() do
    %{}
  end
end
