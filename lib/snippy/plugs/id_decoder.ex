defmodule Snippy.Plugs.IdDecoder do
  @moduledoc """
  Parses string ids to integers.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(%{params: %{"id" => id} = params} = conn, _opts) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, _rest} ->
        %{ conn |
          params: Map.put(params, "id", int_id),
          path_params: Map.replace(conn.path_params, "id",  int_id)
        }
      _ ->
        conn
        |> send_resp(400, "couldn't convert string id to integer")
        |> halt()
    end
  end

  def call(%{params: %{"id" => id}} = conn, _opts) when is_integer(id), do: conn

  def call(%{params: %{"id" => _}} = conn, _opts) do
    conn
    |> send_resp(400, "couldn't convert id to integer")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
