defmodule Flix.Protocol.Commands.CreateBatteryStatusListener do
  defstruct [
    listener_id: 0,
    bt_addr: ""
  ]

  @type t :: %__MODULE__{}

  def decode(<<12::8-little,
    listener_id :: 32-little,
    bt_addr :: little-bytes-6>>) do

    %__MODULE__{
      listener_id: listener_id,
      bt_addr: bt_addr
    }
  end

  def encode(%__MODULE__{listener_id: listener_id, bt_addr: bt_addr} = data) do
    bt_addr = Flix.Utils.bluetooth_address_to_binary(bt_addr)

    <<12::8-little, listener_id::32-little, bt_addr :: little-bytes-6>>
  end
end
