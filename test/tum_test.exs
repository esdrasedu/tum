defmodule TumTest do
  use ExUnit.Case
  doctest Tum

  test "greets the world" do
    assert Tum.hello() == :world
  end
end
