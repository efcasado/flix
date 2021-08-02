defmodule Flix do
  ## API
  ## =========================================================================

  def start(module, state, host \\ 'localhost', port \\ 5551) do
    GenServer.start(module, [host, port, module, state])
  end

  def start_link(module, state, host \\ 'localhost', port \\ 5551) do
    GenServer.start_link(module, [host, port, module, state])
  end

  def stop(client) do
    GenServer.cast(client, :stop)
  end

  defp send_command(client, command) do
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command::binary>>
    GenServer.call(client, {:send, packet})
  end

  @doc """
  Retrieve current state about the server.
  """
  def get_info(client) do
    command = %Flix.Protocol.Commands.GetInfo{}
    send_command(client, command)
  end

  def create_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.CreateScanner{scan_id: scan_id}
    send_command(client, command)
  end

  def remove_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.RemoveScanner{scan_id: scan_id}
    send_command(client, command)
  end

  def create_connection_channel(
        client,
        bt_addr,
        conn_id,
        latency_mode \\ Flix.Protocol.Enums.LatencyMode.default(),
        auto_disconnect_time \\ 0
      )

  def create_connection_channel(client, bt_addr, conn_id, latency_mode, auto_disconnect_time) do
    command = %Flix.Protocol.Commands.CreateConnectionChannel{
      bt_addr: bt_addr,
      conn_id: conn_id,
      latency_mode: latency_mode,
      auto_disconnect_time: auto_disconnect_time
    }

    send_command(client, command)
  end

  def remove_connection_channel(client, conn_id) do
    command = %Flix.Protocol.Commands.RemoveConnectionChannel{conn_id: conn_id}
    send_command(client, command)
  end

  def force_disconnect(client, bt_addr) do
    command = %Flix.Protocol.Commands.ForceDisconnect{bt_addr: bt_addr}
    send_command(client, command)
  end

  def change_mode_parameters(
        client,
        conn_id,
        latency_mode \\ Flix.Protocol.Enums.LatencyMode.default(),
        auto_disconnect_time \\ 0
      )

  def change_mode_parameters(client, conn_id, latency_mode, auto_disconnect_time) do
    command = %Flix.Protocol.Commands.ChangeModeParameters{
      conn_id: conn_id,
      latency_mode: latency_mode,
      auto_disconnect_time: auto_disconnect_time
    }

    send_command(client, command)
  end

  def ping(client, ping_id) do
    command = %Flix.Protocol.Commands.Ping{ping_id: ping_id}
    send_command(client, command)
  end

  def get_button_info(client, bt_addr) do
    command = %Flix.Protocol.Commands.GetButtonInfo{bt_addr: bt_addr}
    send_command(client, command)
  end

  def create_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CreateScanWizard{scan_wizard_id: scan_wizard_id}
    send_command(client, command)
  end

  def cancel_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CancelScanWizard{scan_wizard_id: scan_wizard_id}
    send_command(client, command)
  end

  def delete_button(client, bt_addr) do
    command = %Flix.Protocol.Commands.DeleteButton{bt_addr: bt_addr}
    send_command(client, command)
  end

  def create_battery_status_listener(client, listener_id, bt_addr) do
    command = %Flix.Protocol.Commands.CreateBatteryStatusListener{
      listener_id: listener_id,
      bt_addr: bt_addr
    }

    send_command(client, command)
  end

  def remove_battery_status_listener(client, listener_id) do
    command = %Flix.Protocol.Commands.RemoveBatteryStatusListener{listener_id: listener_id}
    send_command(client, command)
  end

  ## Behaviour
  ## =========================================================================
  @callback handle_event(event :: term, state :: term) :: {:ok, term}

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Flix

      use GenServer

      def init([host, port, module, acc]) do
        socket_opts = [:binary, active: :once, packet: :raw]
        {:ok, socket} = :gen_tcp.connect(host, port, socket_opts)
        {:ok, %{socket: socket, size: 0, event: <<>>, module: module, acc: acc}}
      end

      def handle_call({:send, command}, _from, %{socket: socket} = state) do
        resp = :gen_tcp.send(socket, command)
        {:reply, resp, state}
      end

      def handle_cast(:stop, %{socket: socket} = state) do
        :ok = :gen_tcp.close(socket)
        {:stop, :normal, state}
      end

      def handle_info(
            {:tcp, _client, packet},
            %{socket: socket, size: 0, event: <<>>, acc: acc} = state
          ) do
        :inet.setopts(socket, active: :once)

        {events, size, rest} = parse_packet(packet, [])

        new_acc =
          Enum.reduce(
            events,
            acc,
            fn event, acc ->
              {:ok, new_acc} = handle_event(event, acc)
              new_acc
            end
          )

        {:noreply, %{state | size: size, event: rest, acc: new_acc}}
      end

      def handle_info({:tcp, _client, rest}, %{socket: socket, size: size, event: event} = state) do
        # TO-DO: Needs to be reworked as per the above function clause
        :inet.setopts(socket, active: :once)

        rest_size = byte_size(rest)

        cond do
          rest_size > size ->
            IO.puts("Strange!")
            IO.puts("#{inspect(rest)}")
            {:noreply, %{state | size: 0, event: <<>>}}

          rest_size == size ->
            IO.puts("It's a match!")
            event = <<event, rest>>
            event = Flix.Protocol.Events.decode(event)
            IO.puts("#{inspect(event)}")
            {:noreply, %{state | size: 0, event: <<>>}}

          rest_size < size ->
            IO.puts("Gotta wait!")
            {:noreply, %{state | size: size, event: <<event, rest>>}}
        end
      end

      def handle_info(_msg, state), do: {:noreply, state}

      def parse_packet(<<size::16-little, rest::binary>>, _acc) when byte_size(rest) == size do
        event = parse_event(rest)
        {[event], 0, <<>>}
      end

      def parse_packet(<<size::16-little, rest::binary>>, _acc) when byte_size(rest) < size do
        {[], size, rest}
      end

      def parse_packet(<<size::16-little, rest::binary>> = packets, acc)
          when byte_size(rest) > size do
        packet = :binary.part(packets, 2, size)
        event = parse_event(packet)

        rest = :binary.part(packets, 2 + size, byte_size(packets) - (2 + size))

        parse_packet(rest, [event | acc])
      end

      def parse_packet(<<>>, acc) do
        {acc, 0, <<>>}
      end

      def parse_event(event) do
        Flix.Protocol.Events.decode(event)
      end

      # Flic callbacks
      @doc false
      def handle_advertisement_packet(event, state) do
        require Logger

        Logger.debug(
          "No handle_advertisement_packet/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_battery_status(event, state) do
        require Logger

        Logger.debug(
          "No handle_battery_status/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_bluetooth_controller_state_change(event, state) do
        require Logger

        Logger.debug(
          "No handle_bluetooth_controller_state_change/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_button_click_or_hold(event, state) do
        require Logger

        Logger.debug(
          "No handle_button_click_or_hold/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_button_deleted(event, state) do
        require Logger

        Logger.debug(
          "No handle_button_deleted/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_button_single_or_double_click(event, state) do
        require Logger

        Logger.debug(
          "No handle_button_single_or_double_click/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_button_single_or_double_click_or_hold(event, state) do
        require Logger

        Logger.debug(
          "No handle_single_or_double_click_or_hold/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_button_up_or_down(event, state) do
        require Logger

        Logger.debug(
          "No handle_button_up_or_down/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_connection_channel_removed(event, state) do
        require Logger

        Logger.debug(
          "No handle_connection_channel_removed/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_connection_status_changed(event, state) do
        require Logger

        Logger.debug(
          "No handle_connection_status_changed/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_create_connection_channel_response(event, state) do
        require Logger

        Logger.debug(
          "No handle_craete_connection_channel_response/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_get_button_info_response(event, state) do
        require Logger

        Logger.debug(
          "No handle_get_button_info_response/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_get_info_response(event, state) do
        require Logger

        Logger.debug(
          "No handle_get_info_response/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_got_space_for_new_connection(event, state) do
        require Logger

        Logger.debug(
          "No handle_got_space_for_new_connection/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_new_verified_button(event, state) do
        require Logger

        Logger.debug(
          "No handle_new_verified_button/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_no_space_for_new_connection(event, state) do
        require Logger

        Logger.debug(
          "No handle_no_space_for_new_connection/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_ping_response(event, state) do
        require Logger

        Logger.debug(
          "No handle_ping_response/2 clause in #{__MODULE__} provided for #{inspect(event)}"
        )

        {:ok, state}
      end

      @doc false
      def handle_scan_wizard_button_connected(event, state) do
        require Logger

        Logger.debug(
          "No handle_scan_wizard_button_connected/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_scan_wizard_completed(event, state) do
        require Logger

        Logger.debug(
          "No handle_scan_wizard_completed/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_scan_wizard_found_private_button(event, state) do
        require Logger

        Logger.debug(
          "No handle_scan_wizard_found_privcate_button/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      @doc false
      def handle_scan_wizard_found_public_button(event, state) do
        require Logger

        Logger.debug(
          "No handle_scan_wizard_found_public_button/2 clause in #{__MODULE__} provided for #{
            inspect(event)
          }"
        )

        {:ok, state}
      end

      defoverridable handle_advertisement_packet: 2,
                     handle_battery_status: 2,
                     handle_bluetooth_controller_state_change: 2,
                     handle_button_click_or_hold: 2,
                     handle_button_deleted: 2,
                     handle_button_single_or_double_click: 2,
                     handle_button_single_or_double_click_or_hold: 2,
                     handle_button_up_or_down: 2,
                     handle_connection_channel_removed: 2,
                     handle_connection_status_changed: 2,
                     handle_create_connection_channel_response: 2,
                     handle_get_button_info_response: 2,
                     handle_get_info_response: 2,
                     handle_got_space_for_new_connection: 2,
                     handle_new_verified_button: 2,
                     handle_no_space_for_new_connection: 2,
                     handle_ping_response: 2,
                     handle_scan_wizard_button_connected: 2,
                     handle_scan_wizard_completed: 2,
                     handle_scan_wizard_found_private_button: 2,
                     handle_scan_wizard_found_public_button: 2
    end
  end
end
