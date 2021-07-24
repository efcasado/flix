defmodule Flix.Protocol.Events do
  alias Flix.Protocol.Events.{
    AdvertisementPacket,
    CreateConnectionChannelResponse,
    ConnectionStatusChanged,
    ConnectionChannelRemoved,
    ButtonUpOrDown,
    ButtonClickOrHold,
    ButtonSingleOrDoubleClick,
    ButtonSingleOrDoubleClickOrHold,
    NewVerifiedButton,
    GetInfoResponse,
    NoSpaceForNewConnection,
    GotSpaceForNewConnection,
    BluetoothControllerStateChange,
    PingResponse,
    GetButtonInfoResponse,
    ScanWizardFoundPrivateButton,
    ScanWizardFoundPublicButton,
    ScanWizardButtonConnected,
    ScanWizardCompleted,
    ButtonDeleted,
    BatteryStatus
  }

  def decode(<<0::8-little, payload::binary>>) do
    AdvertisementPacket.decode(payload)
  end

  def decode(<<1::8-little, payload::binary>>) do
    CreateConnectionChannelResponse.decode(payload)
  end

  def decode(<<2::8-little, payload::binary>>) do
    ConnectionStatusChanged.decode(payload)
  end

  def decode(<<3::8-little, payload::binary>>) do
    ConnectionChannelRemoved.decode(payload)
  end

  def decode(<<4::8-little, payload::binary>>) do
    ButtonUpOrDown.decode(payload)
  end

  def decode(<<5::8-little, payload::binary>>) do
    ButtonClickOrHold.decode(payload)
  end

  def decode(<<6::8-little, payload::binary>>) do
    ButtonSingleOrDoubleClick.decode(payload)
  end

  def decode(<<7::8-little, payload::binary>>) do
    ButtonSingleOrDoubleClickOrHold.decode(payload)
  end

  def decode(<<8::8-little, payload::binary>>) do
    NewVerifiedButton.decode(payload)
  end

  def decode(<<9::8-little, payload::binary>>) do
    GetInfoResponse.decode(payload)
  end

  def decode(<<10::8-little, payload::binary>>) do
    NoSpaceForNewConnection.decode(payload)
  end

  def decode(<<11::8-little, payload::binary>>) do
    GotSpaceForNewConnection.decode(payload)
  end

  def decode(<<12::8-little, payload::binary>>) do
    BluetoothControllerStateChange.decode(payload)
  end

  def decode(<<13::8-little, payload::binary>>) do
    PingResponse.decode(payload)
  end

  def decode(<<14::8-little, payload::binary>>) do
    GetButtonInfoResponse.decode(payload)
  end

  def decode(<<15::8-little, payload::binary>>) do
    ScanWizardFoundPrivateButton.decode(payload)
  end

  def decode(<<16::8-little, payload::binary>>) do
    ScanWizardFoundPublicButton.decode(payload)
  end

  def decode(<<17::8-little, payload::binary>>) do
    ScanWizardButtonConnected.decode(payload)
  end

  def decode(<<18::8-little, payload::binary>>) do
    ScanWizardCompleted.decode(payload)
  end

  def decode(<<19::8-little, payload::binary>>) do
    ButtonDeleted.decode(payload)
  end

  def decode(<<20::8-little, payload::binary>>) do
    BatteryStatus.decode(payload)
  end

  def decode(event) when is_binary(event) do
    IO.puts("Unknown event: #{inspect(event)}")
    event
  end

  def encode(_data), do: nil
end
