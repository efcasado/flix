defmodule Flix.Protocol.Events.ConnectionChannelRemoved do
  defstruct conn_id: 0,
            removed_reason: Flix.Protocol.Enums.RemovedReason.default()

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          conn_id::unsigned-little-integer-32,
          removed_reason::unsigned-little-integer-8
        >> = _binary
      ) do
    %__MODULE__{
      conn_id: conn_id,
      removed_reason: Flix.Protocol.Enums.RemovedReason.from(removed_reason)
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
