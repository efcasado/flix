defmodule Flix.Protocol.Events.ButtonUpOrDown do
  defstruct [
    conn_id: 0,
    click_type: Flix.Protocol.Enums.ClickType.default(),
    was_queued: false,
    time_diff: 0
  ]

    #@type t :: %__MODULE__{
    #  x: String.t(),
    #  y: boolean,
    #  z: integer
  #}

  def decode(
    <<
    conn_id :: unsigned-little-integer-32,
    click_type :: unsigned-little-integer-8,
    was_queued :: unsigned-little-integer-8,
    time_diff :: unsigned-little-integer-32,
    >> = _binary) do

    %__MODULE__{
      conn_id: conn_id,
      click_type: Flix.Protocol.Enums.ClickType.from(click_type),
      was_queued: was_queued,
      time_diff: time_diff
    }
  end

  def encode(_data) do
    # TODO
    <<1::16-little, 0::8-little>>
  end
end
