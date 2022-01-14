defmodule Snippy.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["text/*"]
  plug :dispatch

  @template_dir "lib/snippy/templates"

  get "/" do
    render(conn, "index.html")
  end

  post "/snippets" do
    snippet = conn.body_params["snippet"] |> Plug.HTML.html_escape()

    conn
    |> put_status(201)
    |> render("snippets/show.html", [snippet: snippet])
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, (status || 200), body)
  end
end
