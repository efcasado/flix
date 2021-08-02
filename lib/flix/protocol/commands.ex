defmodule Flix.Protocol.Commands do
  alias Flix.Protocol.Commands.{
    GetInfo,
    CreateScanner,
    RemoveScanner,
    CreateConnectionChannel,
    RemoveConnectionChannel,
    ForceDisconnect,
    ChangeModeParameters,
    Ping,
    GetButtonInfo,
    CreateScanWizard,
    CancelScanWizard,
    DeleteButton,
    CreateBatteryStatusListener,
    RemoveBatteryStatusListener
  }

  def decode(<<0::8-little, payload::binary>>) do
    GetInfo.decode(payload)
  end

  def decode(<<1::8-little, payload::binary>>) do
    CreateScanner.decode(payload)
  end

  def decode(<<2::8-little, payload::binary>>) do
    RemoveScanner.decode(payload)
  end

  def decode(<<3::8-little, payload::binary>>) do
    CreateConnectionChannel.decode(payload)
  end

  def decode(<<4::8-little, payload::binary>>) do
    RemoveConnectionChannel.decode(payload)
  end

  def decode(<<5::8-little, payload::binary>>) do
    ForceDisconnect.decode(payload)
  end

  def decode(<<6::8-little, payload::binary>>) do
    ChangeModeParameters.decode(payload)
  end

  def decode(<<7::8-little, payload::binary>>) do
    Ping.decode(payload)
  end

  def decode(<<8::8-little, payload::binary>>) do
    GetButtonInfo.decode(payload)
  end

  def decode(<<9::8-little, payload::binary>>) do
    CreateScanWizard.decode(payload)
  end

  def decode(<<10::8-little, payload::binary>>) do
    CancelScanWizard.decode(payload)
  end

  def decode(<<11::8-little, payload::binary>>) do
    DeleteButton.decode(payload)
  end

  def decode(<<12::8-little, payload::binary>>) do
    CreateBatteryStatusListener.decode(payload)
  end

  def decode(<<13::8-little, payload::binary>>) do
    RemoveBatteryStatusListener.decode(payload)
  end

  # def encode(command) do
  #   encoded_command = _encode(command)
  #   size = byte_size(encoded_command)
  #   <<size::16-little, encoded_command :: binary>>
  # end

  # def encode(%GetInfo{} = data) do
  #   GetInfo.encode(data)
  # end

  # def encode(%GetButtonInfo{} = data) do
  #   GetButtonInfo.encode(data)
  # end

  def encode(%command{} = data) do
    apply(command, :encode, [data])
  end
end
