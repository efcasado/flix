defmodule Flix.Protocol.Events.AdvertisementPacket do
  defstruct scan_id: 0,
            bt_addr: "",
            name_length: 0,
            name: "",
            rssi: 0,
            is_private: false,
            already_verified: false,
            already_connected_to_this_device: false,
            already_connected_to_other_device: false

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          scan_id::unsigned-integer-32,
          bt_addr::little-bytes-6,
          name_length::unsigned-little-integer-8,
          name::unsigned-little-integer-128,
          rssi::signed-little-integer-8,
          is_private::unsigned-little-integer-8,
          already_verified::unsigned-little-integer-8,
          already_connected_to_this_device::unsigned-little-integer-8,
          already_connected_to_other_device::unsigned-little-integer-8
        >> = _binary
      ) do
    bt_addr = Flix.Utils.bluetooth_address_from_binary(bt_addr)

    nl2 = name_length * 8

    %__MODULE__{
      scan_id: scan_id,
      bt_addr: bt_addr,
      name_length: name_length,
      name: <<name::size(nl2)>> |> String.reverse(),
      rssi: rssi,
      is_private: is_private,
      already_verified: already_verified,
      already_connected_to_this_device: already_connected_to_this_device,
      already_connected_to_other_device: already_connected_to_other_device
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
