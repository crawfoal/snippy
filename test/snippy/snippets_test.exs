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

  describe "update/1" do
    test "it persists the update" do
      %{id: id} = Snippets.create("I gonna be updated!")

      new_snippet_text = "Yes! I can be updated!"
      Snippets.update(id, new_snippet_text)

      assert %{id: ^id, text: ^new_snippet_text} = Snippets.by_id(id)
    end
  end

  describe "history/1" do
    test "it returns all versions" do
      text_v1 = "Charlotte, oh wise one, save my life!"
      %{id: id} = Snippets.create(text_v1)
      text_v2 = "Charlotte is brilliant!"
      Snippets.update(id, text_v2)
      text_v3 = "Bye Charlotte ;("
      Snippets.update(id, text_v3)

      assert [ %{text: ^text_v3}, %{text: ^text_v2}, %{text: ^text_v1} ] = Snippets.history(id)
    end
  end
end
