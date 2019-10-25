defmodule Tum.ProofOfWork do

  alias Tum.{Vault, Block}

  def hash(block) do
    :TODO_POW_HASH
  end

  def is_valid?(chain, difficulty) when is_list(chain) do
    :TODO_POW_VALID_CHAIN
  end

  def ghost_block(), do: %Block{hash: "", height: 0}

  def is_valid?(block, last_block, difficulty) do
    :TODO_POW_VALID_BLOCK
  end

end

