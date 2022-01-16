defmodule Snippy.Store do
  use Agent

  alias Snippy.Snippet
  alias Snippy.Store.State

  def start_link(_opts) do
    Agent.start_link(fn -> %State{} end, name: __MODULE__)
  end

  def put(%Snippet{} = snippet) do
    Agent.get_and_update(__MODULE__, &State.put(&1, snippet))
  end

  def get(id) do
    Agent.get(__MODULE__, &State.get(&1, id))
  end

  def get_snippet_versions(id) do
    Agent.get(__MODULE__, fn state -> Map.get(state.snippets, id) end)
  end

  def update(id, new_text) do
    Agent.get_and_update(__MODULE__, &State.update(&1, id, new_text))
  end
end
