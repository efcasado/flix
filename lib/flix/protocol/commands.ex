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

  def decode(<<0 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.GetInfo.decode(payload)
  end
  def decode(<<1 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateScanner.decode(payload)
  end
  def decode(<<2 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveScanner.decode(payload)
  end
  def decode(<<3 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateConnectionChannel.decode(payload)
  end
  def decode(<<4 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveConnectionChannel.decode(payload)
  end
  def decode(<<5 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.ForceDisconnect.decode(payload)
  end
  def decode(<<6 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.ChangeModeParameters.decode(payload)
  end
  def decode(<<7 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.Ping.decode(payload)
  end
  def decode(<<8 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.GetButtonInfo.decode(payload)
  end
  def decode(<<9 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateScanWizard.decode(payload)
  end
  def decode(<<10 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CancelScanWizard.decode(payload)
  end
  def decode(<<11 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.DeleteButton.decode(payload)
  end
  def decode(<<12 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateBatteryStatusListener.decode(payload)
  end
  def decode(<<13 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveBatteryStatusListener.decode(payload)
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
