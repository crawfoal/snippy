defmodule Snippy.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test
  import PhoenixPlugTestPatch

  alias Snippy.{ Router, Snippets }

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

  test "POST /snippets accepts form encoded data and redirects to snippet show page" do
    conn =
      conn(:post, "/snippets", "snippet=This+is+a+fun+exercise%21")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")


    conn = Router.call(conn, @opts)

    redirect_path = redirected_to(conn)
    assert String.match?(redirect_path, ~r/\/snippets\/\d+/)

    conn = conn(:get, redirect_path)
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/This is a fun exercise!/)
  end

  test "snippet show template escapes js/html" do
    conn =
      conn(:post, "/snippets", "snippet=%3CSCRIPT+type%3D%22text%2Fjavascript%22%3E%0D%0Avar+adr+%3D+%27..%2Fevil.php%3Fcakemonster%3D%27+%2B+escape%28document.cookie%29%3B%0D%0A%3C%2FSCRIPT%3E")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")


    conn = Router.call(conn, @opts)

    redirect_path = redirected_to(conn)
    assert String.match?(redirect_path, ~r/\/snippets\/\d+/)

    conn = conn(:get, redirect_path)
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    refute String.match?(conn.resp_body, ~r/\<SCRIPT/)
    refute String.match?(conn.resp_body, ~r/\<\/SCRIPT\>/)
  end

  test "GET /snippets/:id returns 404 if the snippet doesn't exist" do
    conn = conn(:get, "/snippets/923839438")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "POST /snippets/:id updates snippet and redirects to snippet show page" do
    snippet_text = "I will be updated"
    snippet = Snippets.create(snippet_text)
    conn =
      conn(:post, "/snippets/#{snippet.id}", "snippet=I+have+been+updated")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")

    conn = Router.call(conn, @opts)

    redirect_path = redirected_to(conn)
    assert String.match?(redirect_path, ~r/\/snippets\/\d+/)

    conn = conn(:get, redirect_path)
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/I have been updated/)
  end

  test "GET /snippets/:id/edit shows edit form" do
    snippet_text = "I will be updated"
    snippet = Snippets.create(snippet_text)
    conn = conn(:get, "/snippets/#{snippet.id}/edit")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/Edit Your Snippet/)
    assert String.match?(conn.resp_body, ~r/#{snippet.text}/)
  end

  test "GET /snippets/:id/history shows all versions" do
    text_v1 = "Charlotte, oh wise one, save my life!"
    %{id: id, created_at: created_at_v1} = Snippets.create(text_v1)
    text_v2 = "Charlotte is brilliant!"
    %{created_at: created_at_v2} = Snippets.update(id, text_v2)
    text_v3 = "Bye Charlotte"
    %{created_at: created_at_v3} = Snippets.update(id, text_v3)
    conn = conn(:get, "/snippets/#{id}/history")

    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert String.match?(conn.resp_body, ~r/#{created_at_v1}\: #{text_v1}/)
    assert String.match?(conn.resp_body, ~r/#{created_at_v2}\: #{text_v2}/)
    assert String.match?(conn.resp_body, ~r/#{created_at_v3}\: #{text_v3}/)
  end
end
