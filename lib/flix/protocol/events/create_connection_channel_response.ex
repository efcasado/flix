defmodule Flix.Protocol.Events.CreateConnectionChannelResponse do
  defstruct [
    conn_id: 0,
    error: Flix.Protocol.Enums.CreateConnectionChannelError.default(),
    conn_status: Flix.Protocol.Enums.ConnectionStatus.default()
  ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
  #}

  def decode(
    <<
    conn_id :: unsigned-little-integer-32,
    error :: unsigned-little-integer-8,
    conn_status :: unsigned-little-integer-8
    >> = _binary) do

    %__MODULE__{
      conn_id: conn_id,
      error: Flix.Protocol.Enums.CreateConnectionChannelError.from(error),
      conn_status: Flix.Protocol.Enums.ConnectionStatus.from(conn_status)
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
