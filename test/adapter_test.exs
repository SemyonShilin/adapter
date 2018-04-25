defmodule AdapterTest do
  use ExUnit.Case
  doctest Adapter

  test "greets the world" do
    assert Adapter.hello() == :world
  end
end
