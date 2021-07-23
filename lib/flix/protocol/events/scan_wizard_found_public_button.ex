defmodule Flix.Protocol.Events.ScanWizardFoundPublicButton do
  defstruct [
    scan_wizard_id: 0,
    bt_addr: "",
    name_length: 0,
    name: ""
  ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
  #}

  def decode(
    <<
    scan_wizard_id :: unsigned-little-integer-32,
    bt_addr :: little-bytes-6,
    name_length :: unsigned-little-integer-8,
    name :: unsigned-little-integer-128
    >> = _binary) do

    bt_addr = Flix.Utils.bluetooth_address_from_binary(bt_addr)

    nl2 = name_length * 8

    %__MODULE__{
      bt_addr: bt_addr,
      name_length: name_length,
      name: <<name :: size(nl2)>> |> String.reverse
    }
  end

  def encode(_data) do
    # TODO
    nil
  end
end
