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

  test "root route presents template" do
    conn = conn(:get, "/")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/Create A Snippet/)
  end
end
