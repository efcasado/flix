defmodule Flix.Protocol.Commands.CreateScanWizard do
  defstruct scan_wizard_id: 0

  @type t :: %__MODULE__{}

  def decode(_binary), do: %__MODULE__{}

  def encode(%__MODULE__{scan_wizard_id: scan_wizard_id} = _data) do
    <<9::8-little, scan_wizard_id::unsigned-little-integer-32>>
  end
end
