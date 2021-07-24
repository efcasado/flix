defmodule Flix.Protocol.Events.GetButtonInfoResponse do
  defstruct bt_addr: "",
            uuid: "",
            color_length: 0,
            color: "",
            serial_number_length: 0,
            serial_number: 0,
            flic_version: 0,
            firmware_version: 0

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          bd_addr::little-bytes-6,
          uuid::unsigned-integer-128,
          color_length::unsigned-little-integer-8,
          color::unsigned-little-integer-128,
          serial_number_length::unsigned-little-integer-8,
          serial_number::unsigned-little-integer-128,
          flic_version::unsigned-little-integer-8,
          firmware_version::unsigned-little-integer-32
        >> = _binary
      ) do
    bt_addr = Flix.Utils.bluetooth_address_from_binary(bd_addr)
    uuid = Integer.to_string(uuid, 16)

    cl2 = color_length * 8
    snl2 = serial_number_length * 8

    %__MODULE__{
      bt_addr: bt_addr,
      uuid: uuid,
      color_length: color_length,
      color: <<color::size(cl2)>> |> String.reverse(),
      serial_number_length: serial_number_length,
      serial_number: <<serial_number::size(snl2)>> |> String.reverse(),
      flic_version: flic_version,
      firmware_version: firmware_version
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
