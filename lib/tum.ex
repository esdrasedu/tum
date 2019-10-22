defmodule Tum do
  use GenServer

  alias Tum.{Vault, Block, Network, ProofOfWork, Miner}

  defstruct [:blocks, :vault, :difficulty]

  @type t :: %__MODULE__{
    blocks: [Block.t],
    vault: Pid.t,
    difficulty: Integer.t
  }

  def start_link([]) do
    [genesis: genesis, difficulty: difficulty] = Application.get_env(:tum, Tum)
    [private_key: private_key] = Application.get_env(:tum, Vault)
    vault_args = private_key
    |> case do
         private_key when is_bitstring(private_key) ->
           [private_key: private_key |> Base.decode16!()]
         nil -> [private_key: :undefined]
       end
    {:ok, vault} = GenServer.start_link(Vault, vault_args);

    blocks = Network.search_blocks()
    |> case do
         [] -> [genesis]
         all -> all
       end

    :ok = ProofOfWork.is_valid?(blocks, difficulty)

    GenServer.start_link(__MODULE__, %Tum{blocks: blocks, vault: vault, difficulty: difficulty}, name: Tum)
  end

  def init(state) do
    {:ok, state}
  end

  def state() do
    GenServer.whereis(Tum)
    |> :sys.get_state()
  end

  def last_block() do
    GenServer.whereis(Tum)
    |> GenServer.call(:last_block)
  end

  def miner(message \\ "") do
    {:ok, new_block} = GenServer.whereis(Tum)
    |> GenServer.call({:miner, message}, :infinity)
    :ok = Network.broadcast(new_block)
  end

  def new_block(%Block{} = block) do
    GenServer.whereis(Tum)
    |> GenServer.call({:new_block, block})
  end

  def handle_call(:last_block, _from, %{blocks: blocks} = state) do
    {:reply, blocks |> List.last(), state}
  end

  def handle_call({:new_block, block}, _from, %{blocks: blocks, difficulty: difficulty} = state) do
    last_block = blocks |> List.last()
    block
    |> ProofOfWork.is_valid?(last_block, difficulty)
    |> case do
         {:ok, block} ->
           {:reply, {:ok, block}, %{state | blocks: blocks ++ [block]}}
         {:error, errors} ->
           {:reply, {:error, errors}, state}
       end
  end

  def handle_call({:miner, message}, _from, %{blocks: blocks, difficulty: difficulty, vault: vault} = state) do
    last_block = blocks |> List.last()
    {:ok, miner} = GenServer.start_link(Miner, %{previous_block: last_block, difficulty: difficulty, message: message, vault: vault})
    result = Miner.find(miner)
    {:reply, result, state}
  end

end
