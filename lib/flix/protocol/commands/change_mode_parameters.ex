defmodule Flix.Protocol.Commands.ChangeModeParameters do
  defstruct conn_id: 0,
            latency_mode: Flix.Protocol.Enums.LatencyMode.default(),
            auto_disconnect_time: 0

  @type t :: %__MODULE__{}

  def decode(
        <<6::8-little, conn_id::32-little, latency_mode::unsigned-little-integer-8,
          auto_disconnect_time::unsigned-little-integer-16>>
      ) do
    %__MODULE__{
      conn_id: conn_id,
      latency_mode: latency_mode,
      auto_disconnect_time: auto_disconnect_time
    }
  end

  def encode(
        %__MODULE__{
          conn_id: conn_id,
          latency_mode: latency_mode,
          auto_disconnect_time: auto_disconnect_time
        } = _data
      ) do
    latency_mode = Flix.Protocol.Enums.LatencyMode.value(latency_mode)

    <<6::8-little, conn_id::32-little, latency_mode::unsigned-little-integer-8,
      auto_disconnect_time::unsigned-little-integer-16>>
  end
end
