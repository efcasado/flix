defmodule Flix.Protocol.Events.BatteryStatus do
  defstruct listener_id: 0,
            battery_percentage: 0,
            timestamp: 0

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          listener_id::unsigned-little-integer-32,
          battery_percentage::signed-little-integer-8,
          timestamp::unsigned-little-integer-64
        >> = _binary
      ) do
    %__MODULE__{
      listener_id: listener_id,
      battery_percentage: battery_percentage,
      timestamp: timestamp
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
