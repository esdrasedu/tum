defmodule Tum.Vault do
  use GenServer

  @hash_algorithm :sha256

  @curve_signature_algorithm :ecdsa
  @curve_pair_algorithm {:ecdh, :secp256k1}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([private_key: private_key]) do
    {algorithm, curve} = @curve_pair_algorithm
    {public_key, private_key} = :crypto.generate_key(algorithm, curve, private_key)
    {:ok, %{private_key: private_key, public_key: public_key}}
  end

  def hash(_pid, string) when is_binary(string),
    do: :crypto.hash(@hash_algorithm, string)

  def sign(pid, string) when is_bnary(string),
    do: pid |> GenServer.call(:sign, string)

  def is_valid?(string, signature, public_key) do
    {algorithm, curve} = @curve_pair_algorithm
    :crypto.verify(@curve_signature_algorithm, @hash_algorithm, string, [private_key, curve])
  end

  def public_key(pid) do
    pid |> GenServer.call(:public_key)
  end

  def handle_call(:public_key, _from, %{public_key: public_key}),
    do: public_key

  def handle_call({:sign, message}, _from, %{private_key: private_key}) do
    {algorithm, curve} = @curve_pair_algorithm
    :crypto.sign(@curve_signature_algorithm, @hash_algorithm, message, [private_key, curve])
  end

end
