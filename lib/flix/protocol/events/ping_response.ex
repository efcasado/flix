defmodule Flix.Protocol.Events.PingResponse do
  defstruct [
    ping_id: 0
  ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
  #}

  def decode(
    <<
    ping_id :: unsigned-little-integer-32
    >> = _binary) do

    %__MODULE__{
      ping_id: ping_id
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
