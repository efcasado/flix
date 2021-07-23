defmodule Flix.Protocol.Events do

  def parse(<<size :: 16-little, 9 :: 8-little, payload :: binary>>) do
    GetInfoResponse.parse(payload)
  end

  defmodule GetInfoResponse do
    defstruct [
      bluetooth_controller_state: "",
      bluetooth_device_address: "",
      bluetooth_device_address_type: "",
      max_pending_connections: 0,
      max_concurrently_connected_buttons: 0,
      number_pending_connections: 0,
      no_space_for_new_connections: false,
      number_verified_buttons: 0,
      verified_buttons: []
    ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
    #}
  end

  def parse(payload) do
    <<
      bcs :: unsigned-little-integer-8,
      bda :: little-bytes-6,
      bdat :: unsigned-little-integer-8,
      max_pcs :: unsigned-little-integer-8,
      max_ccbs :: unsigned-little-integer-16,
      nb_pcs :: unsigned-little-integer-8,
      no_space :: unsigned-little-integer-8,
      nb_vbs :: unsigned-little-integer-16,
      rest :: binary
    >> = payload

    vbs = []

    %__MODULE__{
      bluetooth_controller_state: bcs,
      bluetooth_device_address: bda,
      bluetooth_device_address_type: bdat,
      max_pending_connections: max_pcs,
      max_concurrently_connected_buttons: max_ccbs,
      number_pending_connections: nb_pcs,
      no_space_for_new_connections: no_space,
      number_verified_buttons: nb_vbs,
      verified_buttons: vbs
    }
  end

end
