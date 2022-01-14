defmodule Snippy.SnippetsTest do
  use ExUnit.Case, async: true

  alias Snippy.Snippets

  describe "create/1" do
    test "it persists the text" do
      snippet_text = "Let's collaborate!"

      snippet = Snippets.create(snippet_text)

      assert snippet.text == snippet_text
      assert %{text: ^snippet_text} = Snippets.by_id(snippet.id)
    end
  end
end
