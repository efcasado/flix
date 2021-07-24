defmodule Flix.Protocol.Events.NewVerifiedButton do
  defstruct bt_addr: ""

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          bt_addr::little-bytes-6
        >> = _binary
      ) do
    bt_addr = Flix.Utils.bluetooth_address_from_binary(bt_addr)

    %__MODULE__{
      bt_addr: bt_addr
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
