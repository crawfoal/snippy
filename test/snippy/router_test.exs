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

  test "POST /snippets accepts form encoded data and responds w/ snippet" do
    conn =
      conn(:post, "/snippets", "snippet=This+is+a+fun+exercise%21")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")


    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    assert String.match?(conn.resp_body, ~r/This is a fun exercise!/)
  end

  test "snippet show template escapes js/html" do
    conn =
      conn(:post, "/snippets", "snippet=%3CSCRIPT+type%3D%22text%2Fjavascript%22%3E%0D%0Avar+adr+%3D+%27..%2Fevil.php%3Fcakemonster%3D%27+%2B+escape%28document.cookie%29%3B%0D%0A%3C%2FSCRIPT%3E")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")


    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201
    refute String.match?(conn.resp_body, ~r/\<SCRIPT/)
    refute String.match?(conn.resp_body, ~r/\<\/SCRIPT\>/)
  end
end
