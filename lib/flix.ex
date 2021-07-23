defmodule Flix do
  @moduledoc """
  Documentation for `Flix`.
  """

  def connect(host \\ 'raspberrypi.local', port \\ 5551) do
    {:ok, client} = Flix.Client.start_link(host, port)
    client
  end

  def disconnect(client) do
    Flix.Client.stop(client)
  end

  def subscribe(client, pid \\ self()) do
    Flix.Client.subscribe(client, pid)
  end

  def unsubscribe(client, pid \\ self()) do
    Flix.Client.unsubscribe(client, pid)
  end

  @doc """
  Retrieve current state about the server.
  """
  def get_info(client, timeout \\ 1_000) do
    command = %Flix.Protocol.Commands.GetInfo{}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>

    # :ok = :gen_tcp.send(client, packet)
    Flix.Client.send(client, packet)
    # {:ok, <<size::16-little>>} = :gen_tcp.recv(client, 2, timeout)

    # {:ok, encoded_event} = :gen_tcp.recv(client, size, timeout)
    # Flix.Protocol.Events.decode(encoded_event)
  end

  def create_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.CreateScanner{scan_id: scan_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def remove_scanner(client, scan_id) do
    command = %Flix.Protocol.Commands.RemoveScanner{scan_id: scan_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def create_connection_channel(client, bt_addr, conn_id, latency_mode \\ Flix.Protocol.Enums.LatencyMode.default(), auto_disconnect_time \\ 0, timeout \\ 1_000)
  def create_connection_channel(client, bt_addr, conn_id, latency_mode, auto_disconnect_time, timeout) do
    command = %Flix.Protocol.Commands.CreateConnectionChannel{bt_addr: bt_addr, conn_id: conn_id, latency_mode: latency_mode, auto_disconnect_time: auto_disconnect_time}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def remove_connection_channel(client, conn_id) do
    command = %Flix.Protocol.Commands.RemoveConnectionChannel{conn_id: conn_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def force_disconnect(client, bt_addr) do
    command = %Flix.Protocol.Commands.ForceDisconnect{bt_addr: bt_addr}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def change_mode_parameters(client, conn_id, latency_mode \\ Flix.Protocol.Enums.LatencyMode.default(), auto_disconnect_time \\ 0)
  def change_mode_parameters(client, conn_id, latency_mode, auto_disconnect_time) do
    command = %Flix.Protocol.Commands.ChangeModeParameters{conn_id: conn_id, latency_mode: latency_mode, auto_disconnect_time: auto_disconnect_time}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def ping(client, ping_id) do
    command = %Flix.Protocol.Commands.Ping{ping_id: ping_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def get_button_info(client, bt_addr, timeout \\ 1_000) do
    command = %Flix.Protocol.Commands.GetButtonInfo{bt_addr: bt_addr}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>

    Flix.Client.send(client, packet)
  end

  def create_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CreateScanWizard{scan_wizard_id: scan_wizard_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def cancel_scan_wizard(client, scan_wizard_id) do
    command = %Flix.Protocol.Commands.CancelScanWizard{scan_wizard_id: scan_wizard_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def delete_button(client, bt_addr) do
    command = %Flix.Protocol.Commands.DeleteButton{bt_addr: bt_addr}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def create_battery_status_listener(client, listener_id, bt_addr) do
    command = %Flix.Protocol.Commands.CreateBatteryStatusListener{listener_id: listener_id, bt_addr: bt_addr}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end

  def remove_battery_status_listener(client, listener_id) do
    command = %Flix.Protocol.Commands.RemoveBatteryStatusListener{listener_id: listener_id}
    encoded_command = Flix.Protocol.Commands.encode(command)
    size = byte_size(encoded_command)
    packet = <<size::16-little, encoded_command :: binary>>
    Flix.Client.send(client, packet)
  end
end
