defmodule Tum.Vault do
  use GenServer

  @moduledoc """
  That module contains all crypto needs

  Tip 1 -> OTP has all you need, just try search at :crypto

  Tip 2 -> You don't need guest with algorithm we are using, it is in module attributes
  """
  @hash_algorithm :sha256

  @signature_algorithm :ecdsa
  @pair_algorithm :ecdh
  @pair_algorithm_curve :secp256k1

  def start_link(args \\ [private_key: nil]) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([private_key: private_key]) do
    :TODO
    {:ok, :TODO}
  end

  def hash(string) when is_binary(string) do
    :TODO_HASH
  end

  def sign(pid, string) when is_binary(string) do
    :TODO_SIGN
  end

  def is_valid?(string, signature, public_key) when is_bitstring(signature) and is_bitstring(string) and is_bitstring(public_key) do
    :TODO_VALID
  end

  def public_key(pid) do
    :TODO_PUBLIC_KEY
  end

  def private_key(pid) do
    :TODO_PRIVATE_KEY
  end

end
