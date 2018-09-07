defmodule Slack.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Slack.Router

  @opts Router.init([])

  test "returns health check" do
    conn =
      conn(:get, "/health")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "returns get /" do
    conn =
      conn(:get, "/")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "compliment"
  end

  test "returns error for unknown route" do
    conn =
      conn(:get, "/nonexistent")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body =~ "error"
  end
end
