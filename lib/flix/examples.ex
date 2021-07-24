defmodule Flix.Examples do
  def loop1() do
    receive do
      %Flix.Protocol.Events.ButtonSingleOrDoubleClickOrHold{click_type: click_type} ->
        case click_type do
          Flix.Protocol.Enums.ClickType.SingleClick ->
            IO.puts("Got a single click!")

          Flix.Protocol.Enums.ClickType.DoubleClick ->
            IO.puts("Got a double click!")

          Flix.Protocol.Enums.ClickType.Hold ->
            IO.puts("Got a hold!")
        end

        loop1()
    end
  end

  def test1() do
    spawn(&Flix.Examples.loop1/0)
  end

  def loop2() do
    receive do
      %Flix.Protocol.Events.ButtonUpOrDown{click_type: click_type} ->
        case click_type do
          Flix.Protocol.Enums.ClickType.Up ->
            IO.puts("Up!")

          Flix.Protocol.Enums.ClickType.Down ->
            IO.puts("Down!")
        end

        loop1()
    end
  end

  def test2() do
    spawn(&Flix.Examples.loop2/0)
  end
end
