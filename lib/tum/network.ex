defmodule Tum.Network do
  use GenServer

  alias Tum.Block

  def start_link([mdns: mdns]) do
    if(mdns) do
      :ok = Mdns.Server.start()
      :ok = Mdns.Client.start()
    end
    GenServer.start_link(__MODULE__, [mdns: mdns], name: __MODULE__)
  end

  def init([mdns: mdns]) do
    :ok = my_ip()
    |> Mdns.Server.set_ip()

    host = hostname()

    services = [
      # create domain for an ip
      %Mdns.Server.Service{domain: "#{host}.local", data: :ip, ttl: 120, type: :a},

      # make service discoverable
      %Mdns.Server.Service{domain: "_services._dns-sd._udp.local", data: "_tum._tcp.local", ttl: 120, type: :ptr},

      # register service to type
      %Mdns.Server.Service{domain: "_tum._tcp.local", data: "#{host}._tum._tcp.local", ttl: 120, type: :ptr},

      # point service to our domain
      %Mdns.Server.Service{domain: "#{host}._tum._tcp.local",  data: {0, 0, 4369, '#{host}.local'}, ttl: 120, type: :srv},

      # empty txt service
      %Mdns.Server.Service{domain: "#{host}._tum._tcp.local", data: [], ttl: 120, type: :txt}
    ]

    if(mdns) do
      :ok = services |> Enum.each(&Mdns.Server.add_service/1)

      Mdns.EventManager.register()
      Mdns.Client.query("_tum._tcp.local")
    end

    {:ok, services}
  end

  def handle_info({:"_tum._tcp.local", %{ip: ip}}, state) do
    get_nodes(ip)
    {:noreply, state}
  end
  def handle_info(_msg, state), do: {:noreply, state}

  def get_nodes(ip) when is_tuple(ip) do
    ip
    |> Tuple.to_list()
    |> Enum.join(".")
    |> String.to_atom()
    |> get_nodes()
  end

  def get_nodes(host) when is_atom(host) do
    [host]
    |> :net_adm.world_list()
    |> connect_node()
  end

  defp connect_node([node | tail]) do
    node
    |> Node.connect()
    connect_node(tail)
  end
  defp connect_node([]), do: :ok

  defp my_ip() do
    {:ok, [{ip, _mask, _submask} | _tail]} = :inet.getif()
    ip
  end

  defp hostname() do
    :erlang.node()
    |> to_string()
    |> String.replace("@", "-")
  end

  def search_blocks() do
    {response, _error} = :rpc.multicall(Tum, :blocks, [], :infinity)
    response
  end

  def broadcast(%Block{} = block) do
    :rpc.multicall(Tum, :new_block, [block], :infinity)
    :ok
  end

end
