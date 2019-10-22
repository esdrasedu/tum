defmodule Tum.ProofOfWork do

  alias Tum.{Vault, Block}

  def hash(block) do
    "#{block.height}#{block.previous_hash}#{block.difficulty}#{block.message}#{block.nounce}"
    |> Vault.hash()
  end

  def is_valid?(chain, difficulty) do
    chain
    |> Enum.reverse()
    |> check_recursive(difficulty)
  end

  def check_recursive(blocks, difficulty), do: check_recursive(blocks, difficulty, blocks)
  def check_recursive([block | tail], difficulty, blocks) do
    last_block = tail
    |> case do
         [last_block | _] -> last_block
         [] -> %Block{hash: "", height: 0}
       end
    is_valid?(block, last_block, difficulty)
    |> case do
         {:ok, _block} -> check_recursive(tail, difficulty, blocks)
         {:error, errors} -> {:error, %{block: block, errors: errors}}
    end
  end
  def check_recursive([], _difficulty, blocks), do: {:ok, blocks |> Enum.reverse()}

  def is_valid?(block, last_block, difficulty) do
    []
    |> validate_hash(block)
    |> validate_previous_block(block, last_block)
    |> validate_difficulty(block, difficulty)
    |> validate_sign(block)
    |> case do
         [] -> {:ok, block}
         errors -> {:error, errors}
       end
  end

  defp validate_hash(errors, block) do
    if(hash(block) != block.hash) do
      errors ++ [:block_hash_invalid]
    else
      errors
    end
  end

  defp validate_previous_block(errors, %{previous_hash: previous_hash}, %{hash: hash}) do
    if(hash != previous_hash) do
      errors ++ [:previous_hash_invalid]
    else
      errors
    end
  end

  defp validate_difficulty(errors, block, difficulty) do
    current_difficulty = calculate_0_prefix(block.hash)
    if(difficulty > current_difficulty) do
      errors ++ [:block_difficulty_invalid]
    else
      errors
    end
  end

  defp validate_sign(errors, block) do
    if(Vault.is_valid?(block.hash, block.signature, block.public_key)) do
      errors
    else
      errors ++ [:block_sign_invalid]
    end
  end

  def calculate_0_prefix(hash) when is_bitstring(hash) do
    hash
    |> String.split("", trim: true)
    |> calculate_0_prefix(0)
  end
  def calculate_0_prefix(["0" | tail], acc), do: calculate_0_prefix(tail, acc + 1)
  def calculate_0_prefix(_notInit0, acc), do: acc

end

