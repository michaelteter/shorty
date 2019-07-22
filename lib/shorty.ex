defmodule Shorty do
  use GenServer

  # --- API ---

  def start_server(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state)
  end

  # --- Server ---

  def init(), do: {:ok, new_state()}
  def init(initial_state), do: {:ok, initial_state}

  # --- Util ---

  def new_state() do
    %{}
  end
end
