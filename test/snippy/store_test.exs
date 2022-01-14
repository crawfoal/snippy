defmodule Snippy.StoreTest do
  use ExUnit.Case, async: true

  alias Snippy.{ Store, Snippet }

  describe "put/1" do
    test "it persists the text" do
      snippet_text = "Wilbur and Charlotte are best friends."
      snippet = %Snippet{text: snippet_text}

      assert %{id: id, text: ^snippet_text, created_at: created_at} = Store.put(snippet)
      assert is_integer(created_at)
      assert %{text: ^snippet_text} = Store.get(id)
    end
  end

  describe "update/2" do
    test "it persists the update" do
      %{id: id} = Store.put(%Snippet{text: "I gonna be updated!"})

      new_snippet_text = "Cool... I've been updated."
      Store.update(id, new_snippet_text)

      assert %{id: ^id, text: ^new_snippet_text} = Store.get(id)
    end

    test "returns nil when snippet not found" do
      refute Store.update(9292388302, "this snippet shouldn't exist")
    end
  end
end
