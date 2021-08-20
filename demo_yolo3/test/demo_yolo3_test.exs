defmodule DemoYolo3Test do
  use ExUnit.Case
  doctest DemoYolo3

  test "greets the world" do
    assert DemoYolo3.hello() == :world
  end
end
