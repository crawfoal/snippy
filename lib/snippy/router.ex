defmodule Snippy.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded], pass: ["text/*"]
  plug :dispatch

  alias Snippy.{ Snippet, Snippets }

  @template_dir "lib/snippy/templates"

  get "/" do
    render(conn, "index.html")
  end

  get "/snippets/:id" do
    with(
      {id, _rest} <- Integer.parse(id),
      %Snippet{} = snippet <- Snippets.by_id(id)
    ) do
      render(conn, "snippets/show.html", [snippet: snippet])
    else
      _error_or_nil ->
        send_resp(conn, 404, "not found")
    end
  end

  get "/snippets/:id/edit" do
    with(
      {id, _rest} <- Integer.parse(id),
      %Snippet{} = snippet <- Snippets.by_id(id)
    ) do
      render(conn, "snippets/edit.html", [snippet: snippet])
    else
      _error_or_nil ->
        send_resp(conn, 404, "not found")
    end
  end

  post "/snippets/:id" do
    new_snippet_text = conn.body_params["snippet"] |> Plug.HTML.html_escape()
    with(
      {id, _rest} <- Integer.parse(id),
      %Snippet{} = _updated_snippet <- Snippets.update(id, new_snippet_text)
    ) do
      redirect(conn, to: "/snippets/#{id}")
    else
      _error_or_nil ->
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
