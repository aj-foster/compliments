defmodule Slack.Reader do
  @moduledoc """
  Reads and caches the request body for use during verification.

  Taken from https://hexdocs.pm/plug/Plug.Parsers.html#module-custom-body-reader
  """

  @doc """
  Read the request body and cache it for use later.
  """
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
    {:ok, body, conn}
  end
end
