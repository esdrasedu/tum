defmodule Tum.Vault do
  use GenServer

  @hash_algorithm :sha256

  @signature_algorithm :ecdsa
  @pair_algorithm :ecdh
  @pair_algorithm_curve :secp256k1

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([private_key: private_key]) do
    {public_key, private_key} = :crypto.generate_key(@pair_algorithm, @pair_algorithm_curve, private_key)
    {:ok, %{private_key: private_key, public_key: public_key}}
  end

  def hash(string) when is_binary(string),
    do: :crypto.hash(@hash_algorithm, string) |> Base.encode16()

  def sign(pid, string) when is_binary(string),
    do: pid |> GenServer.call({:sign, string})

  def is_valid?(string, signature, public_key) do
    {:ok, signature_binary} = signature |> Base.decode16()
    {:ok, public_key_binary} = public_key |> Base.decode16()
    :crypto.verify(@signature_algorithm, @hash_algorithm, string, signature_binary, [public_key_binary, @pair_algorithm_curve])
  end

  def public_key(pid) do
    pid |> GenServer.call(:public_key)
  end

  def handle_call(:public_key, _from, %{public_key: public_key} = state),
    do: {:reply, public_key |> Base.encode16(), state}

  def handle_call({:sign, message}, _from, %{private_key: private_key} = state) do
    signature = :crypto.sign(@signature_algorithm, @hash_algorithm, message, [private_key, @pair_algorithm_curve])
    |> Base.encode16()
    {:reply, signature, state}
  end

end
