defmodule Snippy.StoreTest do
  use ExUnit.Case, async: false

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
      %{id: id, created_at: orig_version_ts} =
        Store.put(%Snippet{text: "I gonna be updated!"})

      :timer.sleep(1000)
      new_snippet_text = "Cool... I've been updated."
      Store.update(id, new_snippet_text)

      assert %{id: ^id, text: ^new_snippet_text, created_at: new_version_ts} = Store.get(id)
      refute new_version_ts == orig_version_ts
    end

    test "returns nil when snippet not found" do
      refute Store.update(9292388302, "this snippet shouldn't exist")
    end
  end

  describe "get/1" do
    test "returns nil if id isn't present" do
      refute Store.get(9393839394)
    end
  end

  describe "get_snippet_versions/1" do
    test "returns nil if id isn't present" do
      refute Store.get_snippet_versions(9393839394)
    end
  end
end
