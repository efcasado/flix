defmodule Flix.Protocol.Commands.RemoveConnectionChannel do
  defstruct [
    conn_id: 0,
  ]

  @type t :: %__MODULE__{}

  def decode(<<4::8-little,
    conn_id :: 32-little>>) do

    %__MODULE__{
      conn_id: conn_id,
    }
  end

  def encode(%__MODULE__{} = data) do
    <<4::8-little, data.conn_id::32-little>>
  end
end
