defmodule Flix.Protocol.Commands.RemoveBatteryStatusListener do
  defstruct listener_id: 0

  @type t :: %__MODULE__{}

  def decode(_binary), do: %__MODULE__{}

  def encode(%__MODULE__{listener_id: listener_id} = _data) do
    <<13::8-little, listener_id::unsigned-little-integer-32>>
  end
end
