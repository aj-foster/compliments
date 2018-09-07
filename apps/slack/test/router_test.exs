defmodule Slack.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Slack.Router

  @opts Router.init([])

  @example_body "token=xyzz0WbapA4vBCDEFasx0q6G&team_id=T1DC2JH3J&" <>
                  "team_domain=testteamnow&channel_id=G8PSS9T3V&" <>
                  "channel_name=foobar&user_id=U2CERLKJA&" <>
                  "user_name=roadrunner&command=%2Fwebhook-collect" <>
                  "&text=&response_url=https%3A%2F%2Fhooks.slack.com%2F" <>
                  "commands%2FT1DC2JH3J%2F397700885554%2F96rGlfmibIGlgc" <>
                  "ZRskXaIFfN&trigger_id=398738663015.47445629121.803a0" <>
                  "bc887a14d10d2c447fce8b6703c"

  @example_timestamp "1531420618"
  @example_signature "v0=a2114d57b48eac39b9ad189dd8316235a7b4a8d21a10bd27519666489c69b503"

  describe "GET /heath" do
    test "returns health check" do
      conn =
        conn(:get, "/health")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "OK"
    end
  end

  describe "GET /" do
    test "returns informational message" do
      conn =
        conn(:get, "/")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "compliment"
    end
  end

  describe "GET unknown route" do
    test "returns error" do
      conn =
        conn(:get, "/nonexistent")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "error"
    end
  end

  describe "POST /" do
    test "returns message when successful" do
      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", @example_timestamp)
        |> put_req_header("X-Slack-Signature", @example_signature)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "Success"
    end

    test "returns error when missing headers" do
      conn =
        conn(:post, "/", @example_body)
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "error"
    end

    test "returns error when incorrectly signed" do
      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", @example_timestamp)
        |> put_req_header("X-Slack-Signature", @example_signature <> "a")
        |> Router.call(@opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body =~ "error"
    end
  end
end
