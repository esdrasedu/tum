defmodule Tum.Miner do
  use GenServer

  alias Tum.{ProofOfWork, Block, Vault}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{previous_block: previous_block, difficulty: difficulty, message: message, vault: vault }) do
    block = %Block{
      height: previous_block.height + 1,
      previous_hash: previous_block.hash,
      difficulty: difficulty,
      hash: "",
      public_key: Vault.public_key(vault),
      signature: "",
      message: message,
      nounce: 0
    }
    {:ok, %{previous_block: previous_block, difficulty: difficulty, block: block, vault: vault}}
  end

  def find(pid) do
    pid |> GenServer.call(:miner, :infinity)
  end

  def find_valid_block(block, previous_block, difficulty, vault) do
    hash = ProofOfWork.hash(block)
    signature = Vault.sign(vault, hash)
    new_block = %{block | hash: hash, signature: signature}
    ProofOfWork.is_valid?(new_block, previous_block, difficulty)
    |> case do
         {:ok, block} ->
           {:ok, block}
         {:error, _errors} ->
           find_valid_block(%{block | nounce: block.nounce+1}, previous_block, difficulty, vault)
    end
  end

  def handle_call(:miner, _from, %{block: old_block, vault: vault, difficulty: difficulty, previous_block: previous_block} = state) do
    {:ok, block} = find_valid_block(old_block, previous_block, difficulty, vault)
    {:reply, {:ok, block}, %{state | block: block}}
  end

end

