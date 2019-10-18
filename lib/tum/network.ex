defmodule Tum.Network do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, :todo)
  end

  def init(state) do
    {:ok, state}
  end

  def search_blocks() do
    # TODO
    []
  end
end
