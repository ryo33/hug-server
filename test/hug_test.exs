defmodule HugTest do
  use ExUnit.Case
  doctest Hug

  test "greets the world" do
    assert Hug.hello() == :world
  end
end
