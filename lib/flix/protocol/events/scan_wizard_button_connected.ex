defmodule Flix.Protocol.Events.ScanWizardButtonConnected do
  defstruct scan_wizard_id: 0

  # @type t :: %__MODULE__{
  #  x: String.t(),
  #  y: boolean,
  #  z: integer
  # }

  def decode(
        <<
          scan_wizard_id::unsigned-little-integer-32
        >> = _binary
      ) do
    %__MODULE__{
      scan_wizard_id: scan_wizard_id
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
