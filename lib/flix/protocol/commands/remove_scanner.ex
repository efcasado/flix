defmodule Flix.Protocol.Commands.RemoveScanner do
  defstruct [
    scan_id: 0
  ]

  @type t :: %__MODULE__{}

  def decode(_binary), do: %__MODULE__{}

  def encode(%__MODULE__{scan_id: scan_id} = _data) do
    <<2 :: 8-little, scan_id :: unsigned-little-integer-32 >>
  end
end
