defmodule Snippy.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Snippy.Router

  @opts Router.init([])

  test "undefined routes return 404 status" do
    conn = conn(:get, "/not-found")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "not found"
  end
end
