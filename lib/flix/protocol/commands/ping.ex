defmodule Flix.Protocol.Commands.Ping do
  defstruct ping_id: 0

  @type t :: %__MODULE__{}

  def decode(<<7::8-little, ping_id::32-little>>) do
    %__MODULE__{
      ping_id: ping_id
    }
  end

  def encode(%__MODULE__{ping_id: ping_id} = data) do
    <<7::8-little, ping_id::32-little>>
  end
end
