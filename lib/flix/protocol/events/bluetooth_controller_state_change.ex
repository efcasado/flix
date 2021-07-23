defmodule Flix.Protocol.Events.BluetoothControllerStateChange do
  defstruct [
    state: Flix.Protocol.Enums.BluetoothControllerState.default()
  ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
  #}

  def decode(
    <<
    state :: unsigned-little-integer-8
    >> = _binary) do
    %__MODULE__{
      state: Flix.Protocol.Enums.BluetoothControllerState.from(state)
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
