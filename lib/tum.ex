defmodule Tum do
  use GenServer

  require Logger

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
    {:ok, vault} = GenServer.start_link(Vault, [private_key: private_key]);

    {:ok, blocks} = Network.search_blocks()
    |> select_chain([], genesis, difficulty)

    GenServer.start_link(__MODULE__, %Tum{blocks: blocks, vault: vault, difficulty: difficulty}, name: Tum)
  end

  def select_chain([chain | chains], current_chain, genesis, difficulty) do
    with true <- is_list(chain),
         [network_genesis | _tail] <- chain,
           true <- network_genesis == genesis,
           true <- length(current_chain) < length(chain),
         {:ok, blocks} <- ProofOfWork.is_valid?(chain, difficulty) do
      select_chain(chains, blocks, genesis, difficulty)
    else
      _error -> select_chain(chains, current_chain, genesis, difficulty)
    end
  end
  def select_chain([], [], genesis, _difficulty), do: {:ok, [genesis]}
  def select_chain([], current_chain, _genesis, _difficulty), do: {:ok, current_chain}

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

  def blocks() do
    GenServer.whereis(Tum)
    |> GenServer.call(:blocks)
  end

  def mine(message \\ "") do
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

  def handle_call(:blocks, _from, %{blocks: blocks} = state) do
    {:reply, blocks, state}
  end

  def handle_call({:new_block, block}, _from, %{blocks: blocks, difficulty: difficulty} = state) do
    Logger.info("New block: #{block.height} -> #{block.hash}")
    last_block = blocks |> List.last()
    block
    |> ProofOfWork.is_valid?(last_block, difficulty)
    |> case do
         {:ok, block} ->
           {:reply, {:ok, block}, %{state | blocks: blocks ++ [block]}}
         {:error, errors} ->
           Logger.info("Block is invalid: #{block.hash}, error: #{inspect(errors)}")
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
