defmodule Snippy.Snippets do
  alias Snippy.{ Snippet, Store }

  def by_id(id) do
    Store.get(id)
  end

  def create(snippet_text) do
    %Snippet{text: snippet_text}
    |> Store.put()
  end

  def update(id, snippet_text) do
    Store.update(id, snippet_text)
  end
end
