defmodule Snippy.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  @template_dir "lib/snippy/templates"

  get "/" do
    render(conn, "index.html")
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
