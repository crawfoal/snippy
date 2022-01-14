ExUnit.start()

defmodule PhoenixPlugTestPatch do
  # taken from https://github.com/phoenixframework/phoenix/blob/v1.6.6/lib/phoenix/test/conn_test.ex#L434
  def redirected_to(conn, status \\ 302)

  def redirected_to(%Plug.Conn{state: :unset}, _status) do
    raise "expected connection to have redirected but no response was set/sent"
  end

  def redirected_to(conn, status) when is_atom(status) do
    redirected_to(conn, Plug.Conn.Status.code(status))
  end

  def redirected_to(%Plug.Conn{status: status} = conn, status) do
    location = Plug.Conn.get_resp_header(conn, "location") |> List.first
    location || raise "no location header was set on redirected_to"
  end

  def redirected_to(conn, status) do
    raise "expected redirection with status #{status}, got: #{conn.status}"
  end
end
