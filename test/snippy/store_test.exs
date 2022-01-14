defmodule Snippy.StoreTest do
  use ExUnit.Case, async: true

  alias Snippy.{ Store, Snippet }

  describe "put/1" do
    test "it persists the text" do
      snippet_text = "Wilbur and Charlotte are best friends."
      snippet = %Snippet{text: snippet_text}

      assert %{id: id, text: ^snippet_text} = Store.put(snippet)
      assert %{text: ^snippet_text} = Store.get(id)
    end
  end
end
