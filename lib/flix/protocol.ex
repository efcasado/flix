defmodule Flix.Protocol do

  def encode(data) do
    data
  end

  def decode(<<size :: 16-little, 0 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.GetInfo.decode(payload)
  end
  def decode(<<size :: 16-little, 1 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateScanner.decode(payload)
  end
  def decode(<<size :: 16-little, 2 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveScanner.decode(payload)
  end
  def decode(<<size :: 16-little, 3 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateConnectionChannel.decode(payload)
  end
  def decode(<<size :: 16-little, 4 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveConnectionChannel.decode(payload)
  end
  def decode(<<size :: 16-little, 5 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.ForceDisconnect.decode(payload)
  end
  def decode(<<size :: 16-little, 6 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.ChangeModeParameters.decode(payload)
  end
  def decode(<<size :: 16-little, 7 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.Ping.decode(payload)
  end
  def decode(<<size :: 16-little, 8 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.GetButtonInfo.decode(payload)
  end
  def decode(<<size :: 16-little, 9 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateScanWizard.decode(payload)
  end
  def decode(<<size :: 16-little, 10 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CancelScanWizard.decode(payload)
  end
  def decode(<<size :: 16-little, 11 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.DeleteButton.decode(payload)
  end
  def decode(<<size :: 16-little, 12 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateBatteryStatusListener.decode(payload)
  end
  def decode(<<size :: 16-little, 12 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.CreateBatteryStatusListener.decode(payload)
  end
  def decode(<<size :: 16-little, 13 :: 8-little, payload :: binary>>) do
    Flix.Protocol.Commands.RemoveBatteryStatusListener.decode(payload)
  end
end
