defmodule Snippy.Plugs.IdDecoderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Snippy.Plugs.IdDecoder

  test "it converts string ids to integers & updates params and path_params" do
    conn = conn(:get, "/snippets/123") |> Snippy.Router.match([])
    assert %{ params: %{ "id" => id }, path_params: %{ "id" => id } } = IdDecoder.call(conn, [])
    assert is_integer(id)
  end

  test "it leaves integer ids alone" do
    params = %{ "id" => 123 }
    assert %{ params: %{ "id" => id } } = IdDecoder.call(%{ params: params }, [])
    assert is_integer(id)
  end

  test "it ignores connections w/out id param" do
    conn = %{ params: %{ "foo" => "bar" } }
    assert conn == IdDecoder.call(conn, [])
  end

  test "when string id cannot be parsed, it halts w/ a 400 status" do
    conn = conn(:get, "/snippets/fab") |> Snippy.Router.match([])
    assert %{ status: 400, halted: true } = IdDecoder.call(conn, [])
  end
end
