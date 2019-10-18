defmodule Tum do
  use GenServer

  alias Tum.{Vault, Block, Network}

  defstruct [:blocks, :vault]

  @type t :: %__MODULE__{
    blocks: [Block.t]
    vault: Pid.t
  }

  def start_link([]) do
    vault_args = Application.get_env(:tum, Vault)
    vault = GenServer.start_link(Vault, vault_args);

    blocks = Network.search_blocks()

    GenServer.start_link(__MODULE__, %Tum{blocks: blocks, vault: vault})
  end

  def init(state) do
    {:ok, state}
  end

end
