defmodule SnippyTest do
  use ExUnit.Case
  doctest Snippy

  test "greets the world" do
    assert Snippy.hello() == :world
  end
end
