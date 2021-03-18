defmodule FlixTest do
  use ExUnit.Case
  doctest Flix

  test "greets the world" do
    assert Flix.hello() == :world
  end
end
