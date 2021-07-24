defmodule Flix.Protocol.Events.ConnectionStatusChanged do
  defstruct conn_id: 0,
            conn_status: Flix.Protocol.Enums.ConnectionStatus.default(),
            disconnect_reason: Flix.Protocol.Enums.DisconnectReason.default()

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          conn_id::unsigned-little-integer-32,
          conn_status::unsigned-little-integer-8,
          disconnect_reason::unsigned-little-integer-8
        >> = _binary
      ) do
    %__MODULE__{
      conn_id: conn_id,
      conn_status: Flix.Protocol.Enums.ConnectionStatus.from(conn_status),
      disconnect_reason: Flix.Protocol.Enums.DisconnectReason.from(disconnect_reason)
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
