defmodule Flix.Client do
  use GenServer

  ## API
  ##=========================================================================

  def start_link(host \\ 'raspberrypi.local', port \\ 5551)
  def start_link(host, port) do
    # {:ok, socket} = :gen_tcp.connect(host, port, [:binary])
    GenServer.start_link(__MODULE__, [host, port])
  end

  def stop(client) do
    GenServer.cast(client, :stop)
  end

  def subscribe(client, pid \\ self()) do
    GenServer.call(client, {:subscribe, pid})
  end

  def unsubscribe(client, pid \\ self()) do
    GenServer.call(client, {:unsubscribe, pid})
  end

  def send(client, packet) do
    GenServer.call(client, {:send, packet})
  end

  ## GenServer callbacks
  ##=========================================================================

  def init([host, port]) do
    socket_opts = [:binary, active: :once, packet: :raw]
    {:ok, socket} = :gen_tcp.connect(host, port, socket_opts)
    {:ok, %{subscribers: MapSet.new(), socket: socket, size: 0, event: <<>>}}
  end

  def handle_call({:subscribe, pid}, _from, %{subscribers: subscribers} = state) do
    subscribers = MapSet.put(subscribers, pid)
    {:reply, :ok, %{state| subscribers: subscribers}}
  end

  def handle_call({:unsubscribe, pid}, _from, %{subscribers: subscribers} = state) do
    subscribers = MapSet.delete(subscribers, pid)
    {:reply, :ok, %{state| subscribers: subscribers}}
  end

  def handle_call({:send, command}, _from, %{socket: socket} = state) do
    resp = :gen_tcp.send(socket, command)
    {:reply, resp, state}
  end

  def handle_cast(:stop, %{socket: socket} = state) do
    :ok = :gen_tcp.close(socket)
    {:stop, :normal, state}
  end

  def handle_info({:tcp, _client, packet},  %{subscribers: subscribers, socket: socket, size: 0, event: <<>>} = state) do
    # IO.puts "Building TCP message 1"
    :inet.setopts(socket, active: :once)

    {events, size, rest} = parse_packet(packet, [])
    # IO.puts("Events = #{inspect events}")
    Enum.each(subscribers, fn(pid) -> Enum.each(events, fn(event) -> Kernel.send(pid, event) end) end)
    {:noreply, %{state| size: size, event: rest}}
  end
  def handle_info({:tcp, _client, rest},  %{socket: socket, size: size, event: event} = state) do
    # TO-DO: Needs to be reworked as per the above function clause
    # IO.puts "Building TCP message 2"
    :inet.setopts(socket, active: :once)

    rest_size = byte_size(rest)
    cond do
      rest_size > size ->
        IO.puts "Strange!"
        IO.puts "#{inspect rest}"
        {:noreply, %{state | size: 0, event: <<>>}}
      rest_size == size ->
        IO.puts "It's a match!"
        event = <<event, rest>>
        event = Flix.Protocol.Events.decode(event)
        IO.puts "#{inspect event}"
        {:noreply, %{state | size: 0, event: <<>>}}
      rest_size < size ->
        IO.puts "Gotta wait!"
        {:noreply, %{state | size: size, event: <<event, rest>>}}
    end
  end

  def handle_info(_msg, state), do: {:noreply, state}


  def parse_packet(<<size :: 16-little, rest :: binary>>, _acc) when byte_size(rest) == size do
    event = parse_event(rest)
    {[event], 0, <<>>}
  end
  def parse_packet(<<size :: 16-little, rest :: binary>>, _acc) when byte_size(rest) < size do
    {[], size, rest}
  end
  def parse_packet(<<size :: 16-little, rest :: binary>> = packets, acc) when byte_size(rest) > size do
    packet = :binary.part(packets, 2, size)
    event = parse_event(packet)

    rest = :binary.part(packets, 2 + size, byte_size(packets) - (2 + size))

    parse_packet(rest, [event| acc])
  end
  def parse_packet(<<>>, acc) do
    {acc, 0, <<>>}
  end


  def parse_event(event) do
    Flix.Protocol.Events.decode(event)
  end
end
