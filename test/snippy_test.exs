defmodule SnippyTest do
  use ExUnit.Case
  doctest Snippy

  test "host/0" do
    assert Snippy.host() == "localhost:4001"
  end
end
