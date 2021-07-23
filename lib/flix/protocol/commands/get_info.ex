defmodule Flix.Protocol.Commands.GetInfo do
  defstruct []

  @type t :: %__MODULE__{}

  def decode(_binary), do: %__MODULE__{}
  def encode(_data), do: <<0::8-little>>
end
