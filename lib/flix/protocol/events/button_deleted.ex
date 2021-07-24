defmodule Flix.Protocol.Events.ButtonDeleted do
  defstruct bt_addr: "",
            deleted_by_this_client: false

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          bt_addr::little-bytes-6,
          deleted_by_this_client::unsigned-integer-8
        >> = _binary
      ) do
    bt_addr = Flix.Utils.bluetooth_address_from_binary(bt_addr)

    %__MODULE__{
      bt_addr: bt_addr,
      deleted_by_this_client: deleted_by_this_client
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
