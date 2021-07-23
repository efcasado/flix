defmodule Flix.Protocol.Commands.DeleteButton do
  defstruct [
    bt_addr: ""
  ]

  @type t :: %__MODULE__{}

  def decode(
    <<
    11 :: 8-little,
    bt_addr :: little-bytes-6
    >>) do
    bt_addr = Flix.Utils.bluetooth_address_from_binary(bt_addr)
    %__MODULE__{
      bt_addr: bt_addr
    }
  end

  def encode(%__MODULE__{bt_addr: bt_addr} = _data) do
    bt_addr = Flix.Utils.bluetooth_address_to_binary(bt_addr)
    <<11::8-little, bt_addr :: little-bytes-6>>
  end
end
