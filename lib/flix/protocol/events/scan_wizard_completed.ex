defmodule Flix.Protocol.Events.ScanWizardCompleted do
  defstruct scan_wizard_id: 0,
            result: Flix.Protocol.Enums.ScanWizardResult.default()

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          scan_wizard_id::unsigned-little-integer-32,
          result::unsigned-little-integer-8
        >> = _binary
      ) do
    %__MODULE__{
      scan_wizard_id: scan_wizard_id,
      result: Flix.Protocol.Enums.ScanWizardResult.from(result)
    }
  end

  def encode(_data) do
    # TODO
    <<1::16-little, 0::8-little>>
  end
end
