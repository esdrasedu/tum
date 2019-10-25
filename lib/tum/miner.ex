defmodule Tum.Miner do
  use GenServer

  alias Tum.{ProofOfWork, Block, Vault}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{previous_block: previous_block, difficulty: difficulty, message: message, vault: vault }) do
    :TODO
    {:ok, :TODO}
  end

  def find(pid) do
    pid |> GenServer.call(:miner, :infinity)
  end

  def handle_call(:miner, _from, %{block: old_block, vault: vault, difficulty: difficulty, previous_block: previous_block} = state) do
    :TODO
    {:reply, :TODO, state}
  end

end

