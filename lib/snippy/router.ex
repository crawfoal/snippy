defmodule Snippy.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["text/*"]
  plug Snippy.Plugs.IdDecoder
  plug :dispatch

  alias Snippy.{ Snippet, Snippets }

  @template_dir "lib/snippy/templates"

  get "/" do
    render(conn, "index.html")
  end

  get "/snippets/:id" do
    case Snippets.by_id(conn.params["id"]) do
      %Snippet{} = snippet ->
        render(conn, "snippets/show.html", [snippet: snippet])
      _ ->
        send_resp(conn, 404, "not found")
    end
  end

  get "/snippets/:id/edit" do
    case Snippets.by_id(conn.params["id"]) do
      %Snippet{} = snippet ->
        render(conn, "snippets/edit.html", [snippet: snippet])
      _ ->
        send_resp(conn, 404, "not found")
    end
  end

  get "/snippets/:id/history" do
    case Snippets.history(conn.params["id"]) do
      snippet_versions when is_list(snippet_versions) ->
        render(conn, "snippets/history.html", [snippet_versions: snippet_versions])
      _ ->
        send_resp(conn, 404, "not found")
    end
  end

  post "/snippets/:id" do
    new_snippet_text = conn.body_params["snippet"] |> Plug.HTML.html_escape()
    case Snippets.update(conn.params["id"], new_snippet_text) do
      %Snippet{} ->
        redirect(conn, to: "/snippets/#{conn.params["id"]}")
      _ ->
        send_resp(conn, 404, "not found")
    end
  end

  post "/snippets" do
    snippet_text = conn.body_params["snippet"] |> Plug.HTML.html_escape()
    snippet = Snippets.create(snippet_text)

    redirect(conn, to: "/snippets/#{snippet.id}")
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

  # from Phoenix: https://github.com/phoenixframework/phoenix/blob/v1.6.6/lib/phoenix/controller.ex#L398
  defp redirect(conn, opts) when is_list(opts) do
    url  = url(opts)
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> send_resp(conn.status || 302, body)
  end

  defp url(opts) do
    cond do
      to = opts[:to] -> to
      external = opts[:external] -> external
      true -> raise ArgumentError, "expected :to or :external option in redirect/2"
    end
  end
end
