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
    {:ok, private_key} = private_key
    |> case do
         string when is_bitstring(string) ->
           string |> Base.decode16()
         _other -> {:ok, :undefined}
       end
    {public_key, private_key} = :crypto.generate_key(@pair_algorithm, @pair_algorithm_curve, private_key)
    {:ok, %{private_key: private_key, public_key: public_key}}
  end

  def hash(string) when is_binary(string),
    do: :crypto.hash(@hash_algorithm, string) |> Base.encode16()

  def sign(pid, string) when is_binary(string),
    do: pid |> GenServer.call({:sign, string})

  def is_valid?(string, signature, public_key) when is_bitstring(signature) and is_bitstring(string) and is_bitstring(public_key) do
    {:ok, signature_binary} = signature |> Base.decode16()
    {:ok, public_key_binary} = public_key |> Base.decode16()
    :crypto.verify(@signature_algorithm, @hash_algorithm, string, signature_binary, [public_key_binary, @pair_algorithm_curve])
  end
  def is_valid?(_string, _signature, _public_key), do: false

  def public_key(pid), do: pid |> GenServer.call(:public_key)
  def private_key(pid), do: pid |> GenServer.call(:private_key)

  def handle_call(:public_key, _from, %{public_key: public_key} = state),
    do: {:reply, public_key |> Base.encode16(), state}

  def handle_call(:private_key, _from, %{private_key: private_key} = state),
    do: {:reply, private_key |> Base.encode16(), state}

  def handle_call({:sign, message}, _from, %{private_key: private_key} = state) do
    signature = :crypto.sign(@signature_algorithm, @hash_algorithm, message, [private_key, @pair_algorithm_curve])
    |> Base.encode16()
    {:reply, signature, state}
  end

end
