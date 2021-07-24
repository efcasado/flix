defmodule Flix.Protocol.Events.NoSpaceForNewConnection do
  defstruct max_concurrently_connected_buttons: 0

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          max_concurrently_connected_buttons::unsigned-little-integer-16
        >> = _binary
      ) do
    %__MODULE__{
      max_concurrently_connected_buttons: max_concurrently_connected_buttons
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
