defmodule Flix.Protocol.Commands.CreateConnectionChannel do
  defstruct conn_id: 0,
            bt_addr: "",
            latency_mode: Flix.Protocol.Enums.LatencyMode.default(),
            auto_disconnect_time: 0

  @type t :: %__MODULE__{}

  def decode(
        <<3::8-little, conn_id::32-little, bt_addr::little-bytes-6,
          latency_mode::unsigned-little-integer-8,
          auto_disconnect_time::unsigned-little-integer-16>>
      ) do
    %__MODULE__{
      conn_id: conn_id,
      bt_addr: bt_addr,
      latency_mode: latency_mode,
      auto_disconnect_time: auto_disconnect_time
    }
  end

  def encode(
        %__MODULE__{
          conn_id: conn_id,
          bt_addr: bt_addr,
          latency_mode: latency_mode,
          auto_disconnect_time: auto_disconnect_time
        } = _data
      ) do
    bt_addr = Flix.Utils.bluetooth_address_to_binary(bt_addr)
    latency_mode = Flix.Protocol.Enums.LatencyMode.value(latency_mode)

    <<3::8-little, conn_id::32-little, bt_addr::little-bytes-6,
      latency_mode::unsigned-little-integer-8, auto_disconnect_time::unsigned-little-integer-16>>
  end
end
