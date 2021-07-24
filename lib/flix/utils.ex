defmodule Flix.Utils do
  def bluetooth_address_from_binary(<<bt_addr::little-bytes-6>>) do
    for(<<b::unsigned-little-integer-8 <- bt_addr>>, do: Integer.to_string(b, 16))
    |> Enum.reverse()
    |> Enum.join(":")
  end

  def bluetooth_address_to_binary(bt_addr) do
    String.split(bt_addr, ":")
    |> Enum.map(&String.to_integer(&1, 16))
    |> Enum.reduce(<<>>, fn x, acc -> <<x::unsigned-little-integer-8, acc::binary>> end)
  end

  def binary_to_bitstring(binary) do
    for <<b::1 <- binary>>, do: b
  end
end
