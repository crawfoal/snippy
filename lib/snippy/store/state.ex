defmodule Snippy.Store.State do
  defstruct [snippets: %{}, size: 0]

  alias Snippy.Snippet

  def put(orig_state, %Snippet{} = snippet) do
      created_at = DateTime.utc_now() |> DateTime.to_unix()
      snippet = %{ snippet | id: orig_state.size, created_at: created_at }
      new_state = %{ orig_state |
        size: orig_state.size + 1,
        snippets: Map.put(orig_state.snippets, orig_state.size, [ snippet ])
      }
      { snippet, new_state }
  end

  def get(%{ snippets: snippets }, id) when is_map_key(snippets, id) do
    Map.get(snippets, id) |> List.first()
  end

  def get(_state, _id), do: nil

  def update(%{ snippets: snippets } = orig_state, id, new_text)
  when is_map_key(snippets, id) do
    [ previous_version | _rest ] = versions = snippets[id]
    created_at = DateTime.utc_now() |> DateTime.to_unix()
    updated_snippet = %{ previous_version | text: new_text, created_at: created_at }
    new_state = %{ orig_state | snippets: Map.put(snippets, id, [ updated_snippet | versions ]) }

    { updated_snippet, new_state }
  end

  def update(state, _id, _new_text), do: { nil, state }
end
