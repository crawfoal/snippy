defmodule Snippy.Store do
  use Agent

  defstruct [snippets: %{}, size: 0]

  alias Snippy.Snippet

  def start_link(_opts) do
    Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
  end

  def put(%Snippet{} = snippet) do
    Agent.get_and_update(__MODULE__, fn orig_state ->
      created_at = DateTime.utc_now() |> DateTime.to_unix()
      snippet_with_id = %{ snippet | id: orig_state.size, created_at: created_at }
      new_state = %{ orig_state |
        size: orig_state.size + 1,
        snippets: Map.put(orig_state.snippets, orig_state.size, snippet_with_id)
      }
      { snippet_with_id, new_state }
    end)
  end

  def get(id) do
    Agent.get(__MODULE__, fn state -> Map.get(state.snippets, id) end)
  end

  def update(id, new_text) do
    Agent.get_and_update(__MODULE__, fn %{ snippets: snippets } = orig_state ->
      case snippets[id] do
        %Snippet{} = orig_snippet ->
          updated_snippet = %{ orig_snippet | text: new_text }
          new_state = %{ orig_state | snippets: Map.put(snippets, id, updated_snippet) }

          { updated_snippet, new_state }

        nil ->
          { nil, orig_state }
      end
    end)
  end
end
