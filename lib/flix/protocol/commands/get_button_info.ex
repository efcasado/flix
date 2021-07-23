defmodule Flix.Protocol.Commands.GetButtonInfo do
  alias __MODULE__

  defstruct [
    bt_addr: ""
  ]

  @type t :: %__MODULE__{}

  def decode(_binary), do: %__MODULE__{}
  def encode(%GetButtonInfo{} = data) do
    bt_addr = data.bt_addr
    bt_addr = Flix.Utils.bluetooth_address_to_binary(bt_addr)
    <<8::8-little, bt_addr :: little-bytes-6>>
  end
end
