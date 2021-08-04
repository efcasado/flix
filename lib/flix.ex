defmodule Flix do
  @moduledoc ~S"""
  Flix is an Elixir client for the [Flic](https://flic.io/) smart button.

  Flic buttons don't connect directly to `Flix` nor the other way around. Flic buttons connect
  to a `flicd` via bluetooth. `Flix` applications also connect to `flicd` but via a TCP. See
  the diagram below.

  ```
  +------------+  command(s)  +---------+               +---------------+
  |            +------------->|         |               |               |
  |  Flix App  |     TCP      |  flicd  |<--------------+  Flic Button  |
  |            |<-------------+         |   Bluetooth   |               |
  +------------+   event(s)   +---------+               +---------------+
  ```

  You can find more information about Flic's `flicd` in its
  [official page](https://github.com/50ButtonsEach/fliclib-linux-hci).

  Writing a Flix application is as simple as defining a new Elixir module,
  using Flix's `__using__` macro (ie. `use Flix`) and implementing Flix's
  `handle_event/2` callback function.

  ```elixir
  defmodule MyFlixApp do
    use Flix

    def handle_event(event, state) do
      new_state = do_something(event, state)
      {:ok, new_state}
    end
  end
  ```

  Below is a full example of a Flix application where a counter is initialised to `0`
  and increased or decreased by one when someone does single- or double-clicks a Flic
  button, respectively. The code makes the following assumptions:
  - `flicd` is running and reachable on `raspberrypi.local:5551`.
  - The Flic button (ie. `"80:E4:DA:78:45:1B"`) has already been paired with `flicd`.


  ```elixir
  defmodule Flix.Examples.Counter do
    use Flix

    alias Flix.Protocol.Events.ButtonSingleOrDoubleClickOrHold
    alias Flix.Protocol.Enums.ClickType

    def start(host \\ 'raspberrypi.local', port \\ 5551) do
      {:ok, client} = Flix.start(__MODULE__, 0, host, port)
      :ok = set_up(client)
      {:ok, client}
    end

    def start_link(host \\ 'raspberrypi.local', port \\ 5551) do
      {:ok, client} = Flix.start_link(__MODULE__, 0, host, port)
      :ok = set_up(client)
      {:ok, client}
    end

    def set_up(client) do
      :ok = Flix.create_connection_channel(client, "80:E4:DA:78:45:1B", 1)
    end

    def stop(client) do
      :ok = Flix.stop(client)
    end

    def handle_event(
      %ButtonSingleOrDoubleClickOrHold{click_type: ClickType.SingleClick},
      count
    ) do
      new_count = count + 1
      IO.puts "Count = #{new_count}"
      {:ok, new_count}
    end
    def handle_event(
      %ButtonSingleOrDoubleClickOrHold{click_type: ClickType.DoubleClick},
      count
    ) do
      new_count = count - 1
      IO.puts "Count = #{new_count}"
      {:ok, new_count}
    end
    def handle_event(event, count) do
      require Logger
      Logger.debug("No handle_event/2 clause in #{__MODULE__} for #{inspect(event)}")
      {:ok, count}
    end
  end
  ```
  """

  ## API
  ## =========================================================================

  @doc """
  Starts a new `Flix` client without links.

  See `start_link/4` for more details.
  """
  def start(module, state, host \\ 'localhost', port \\ 5551) do
    GenServer.start(module, [host, port, module, state])
  end

  @doc """
  Starts a new `Flix` client linked to the current process.

  This is often used to start the `Flix` as part of a supervision tree.

  A `Flix` client is nothing but a `GenServer` sprinkled with some custom logic.
  See `GenServer.start_link/3` for more details.
  """
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
  Retrieves the current state of the server (ie. `flicd` process the client is connected to).

  After executing this function, `flicd` sends a `Flix.Protocol.Events.GetInfoResponse` event to the client.
  """
  def get_info(client) do
    command = %Flix.Protocol.Commands.GetInfo{}
    send_command(client, command)
  end

  @doc """
  Creates a scanner with the given `scan_id`.

  After executing this function, `flicd` sends a `Flix.Protocol.Events.AdvertisementPacket` event for each
  advertisement packet received from a Flic button by the server (ie. `flicd`).
  `Flix.Protocol.Event.AdvertisementPacket` events are annotated with the provided `scan_id`.

  To stop receiving advertisement events use `remove_scanner/2`.

  If there already exists an active scanner with the provided `scan_id`, the execution of
  this function has no effect.
  """
  def create_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.CreateScanner{scan_id: scan_id}
    send_command(client, command)
  end

  @doc """
  Removes the scanner with the given `scan_id`.

  The client will stop receiving `Flix.Protocol.Event.AdvertisementPacket` events.
  """
  def remove_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.RemoveScanner{scan_id: scan_id}
    send_command(client, command)
  end

  @doc """
  Creates a connection channel for a Flic button with the given bluetooth address. You assign a unique
  `conn_id` for this connection channel that will later be used in commands and events to refer to this
  connection channel.

  After executing this function, `flicd` sends a `Flix.Protocol.Events.CreateConnectionChannelResponse`
  event to the client.

  When a connection channel is created, the client starts listening for button events originating from the
  provided Flic button. There are four types of button events (ie. `Flix.Protocol.Events.ButtonUpOrDown`,
  `Flix.Protocol.Events.ButtonClickOrHold`, `Flix.Protocol.Events.ButtonSingleOrDoubleClick`,
  `Flix.Protocol.Events.ButtonSingleOrDoubleClickOrHold`). These events are annotated with the provided
  `conn_id`.

  To stop receiving button events use `remove_connection_channel/2`.

  If there already exists a connection channel with the provided `conn_id`, the execution of this function
  has no effect.
  """
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

  @doc """
  Removes a previously created connection channel.

  After executing this function, no further button events will be sent for this channel.
  If there are no other connection channels active to this Flic button (from neither the provided client
  nor other clieents), the physical bluetooth connection between `flicd` and the Flic button is
  disconnected.
  """
  def remove_connection_channel(client, conn_id) do
    command = %Flix.Protocol.Commands.RemoveConnectionChannel{conn_id: conn_id}
    send_command(client, command)
  end

  @doc """
  Removes all connection channels among all clients for the specified Flic button.
  """
  def force_disconnect(client, bt_addr) do
    command = %Flix.Protocol.Commands.ForceDisconnect{bt_addr: bt_addr}
    send_command(client, command)
  end

  @doc """
  Changes the accepted latency for this connection channel and the auto disconnect time.

  The latency mode is applied immediately but the auto disconnect time is applied the next time
  the Flic button gets connected.
  """
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

  @doc """
  Pings the server (ie. `flicd`).

  After executing this function, `flicd` sends a `Flix.Protocol.Event.PingResponse` event to the client.
  """
  def ping(client, ping_id) do
    command = %Flix.Protocol.Commands.Ping{ping_id: ping_id}
    send_command(client, command)
  end

  @doc """
  Gets information about a Flic button. The button must have been previously paired with the server (ie.`flicd`).

  After executing thisfunction, `flicd` sends a `Flic.Protocol.Event.GetButtonInfoResponse` to the client.
  """
  def get_button_info(client, bt_addr) do
    command = %Flix.Protocol.Commands.GetButtonInfo{bt_addr: bt_addr}
    send_command(client, command)
  end

  @doc """
  Starts a scan wizard with the provided `scan_wizard_id`.

  If there already exists a scan wizard with the same `scan_wizard_id`, the execution of this funcion
  has no effect.
  """
  def create_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CreateScanWizard{scan_wizard_id: scan_wizard_id}
    send_command(client, command)
  end

  @doc """
  Cancels a scan wizard that was previously started.

  If there exists a scan wizard with the provided `scan_wizard_id`, it is cancelled and `flicd` sends a
  `Flix.Protocol.Events.ScanWizardCompleted` event to the client with the reason set to
  `Flix.Protocol.Enums.ScanWizardResult.CancelledByUser`.
  """
  def cancel_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CancelScanWizard{scan_wizard_id: scan_wizard_id}
    send_command(client, command)
  end

  @doc """
  Deletes a Flic button.

  If the button exists in the list of verified buttons, all connection channels will be removed for
  all clients for this button. Then, `flicd` sends the `Flix.Protocol.Events.ButtonDeleted` event to all clients.

  If the Flic button does not exist in the list of verified buttons, the execution of this function has no effect
  but a `Flix.Protocol.Events.ButtonDeleted` is anyways sent to the client.
  """
  def delete_button(client, bt_addr) do
    command = %Flix.Protocol.Commands.DeleteButton{bt_addr: bt_addr}
    send_command(client, command)
  end

  @doc """
  Creates a battery status listener for a Flic button.

  If the providede `listener_id` already exists for this client, the execution of this function has no effect.

  After the execution of this function, `flicd` sends a `Flix.Protocol.Events.BatteryStatus` event to the client
  for the specified button. Further `Flix.Protocol.Events.BatteryStatus` events are sent to the client every time
  the battery status of the button changes. This does not usually happen more often than every three hours.
  """
  def create_battery_status_listener(client, listener_id, bt_addr) do
    command = %Flix.Protocol.Commands.CreateBatteryStatusListener{
      listener_id: listener_id,
      bt_addr: bt_addr
    }

    send_command(client, command)
  end

  @doc """
  Removes the battery status listener identified by the provided `listener_id`.
  """
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
