defmodule Tum.Miner do
  use GenServer

  alias Tum.{Block, Vault}

  def init(message, difficulty, block, vault) do
    {:ok, %{message: message, difficulty: difficulty, block: block, vault: vault}}
  end

  def new_block(pid, nounce) do
    pid |> GenServer.call({:new_block, nounce})
  end

  def handle_call({:new_block, nounce}, _from, state) do
    block = %Block{
      height: state.block.height + 1,
      hash: "",
      previous_hash: state.block.hash,
      difficulty: state.difficulty,
      message: state.message,
      nounce: nounce,
      public_key: Vault.public_key(state.vault),
      signature: ""
    }
    hash = ProofOfWork.hash(block);
    signature = Vault.sign(hash);
    %{block | hash: hash, signature: signature}
  end

  def miner(pid) do
    pid |> GenServer.call(:miner)
  end

  def handle_call(:miner, _from, state) do
    
  end
end

