defmodule Flix.Protocol.Events.GetInfoResponse do
  defstruct bluetooth_controller_state: Flix.Protocol.Enums.BluetoothControllerState.default(),
            bluetooth_device_address: "",
            bluetooth_device_address_type: Flix.Protocol.Enums.BdAddrType.default(),
            max_pending_connections: 0,
            max_concurrently_connected_buttons: 0,
            number_pending_connections: 0,
            no_space_for_new_connections: false,
            number_verified_buttons: 0,
            verified_buttons: []

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          bt_controller_state::unsigned-little-integer-8,
          my_bd_addr::little-bytes-6,
          my_bd_addr_type::unsigned-little-integer-8,
          max_pending_connections::unsigned-little-integer-8,
          max_concurrently_connected_buttons::unsigned-little-integer-16,
          current_pending_connections::unsigned-little-integer-8,
          currently_no_space_for_new_connection::unsigned-little-integer-8,
          nb_verified_buttons::unsigned-little-integer-16,
          rest::binary
        >> = _binary
      ) do
    bt_controller_state = Flix.Protocol.Enums.BluetoothControllerState.from(bt_controller_state)
    my_bd_addr = Flix.Utils.bluetooth_address_from_binary(my_bd_addr)
    my_bd_addr_type = Flix.Protocol.Enums.BdAddrType.from(my_bd_addr_type)

    verified_buttons =
      case nb_verified_buttons do
        0 ->
          []

        _n ->
          for <<bd_addr::little-bytes-6 <- rest>>,
            do: Flix.Utils.bluetooth_address_from_binary(bd_addr)
      end

    %__MODULE__{
      bluetooth_controller_state: bt_controller_state,
      bluetooth_device_address: my_bd_addr,
      bluetooth_device_address_type: my_bd_addr_type,
      max_pending_connections: max_pending_connections,
      max_concurrently_connected_buttons: max_concurrently_connected_buttons,
      number_pending_connections: current_pending_connections,
      no_space_for_new_connections:
        if(currently_no_space_for_new_connection == 0, do: false, else: true),
      number_verified_buttons: nb_verified_buttons,
      verified_buttons: verified_buttons
    }
  end

  def encode(_data) do
    # TODO
    <<1::16-little, 0::8-little>>
  end
end
