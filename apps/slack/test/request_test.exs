defmodule Slack.RequestTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Slack.Request

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

  describe "read_and_parse/1" do
    test "returns parsed request" do
      time =
        :os.system_time(:seconds)
        |> to_string()

      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", time)
        |> put_req_header("X-Slack-Signature", @example_signature)

      {body, timestamp, signature} = Request.read_and_parse(conn)

      assert body == @example_body
      assert timestamp == time
      assert signature == @example_signature
    end

    test "returns error if missing timestamp header" do
      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Signature", @example_signature)

      assert {:error, :missing_header} == Request.read_and_parse(conn)
    end

    test "returns error if missing signature header" do
      time =
        :os.system_time(:seconds)
        |> to_string()

      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", time)

      assert {:error, :missing_header} == Request.read_and_parse(conn)
    end
  end

  describe "verify/3" do
    test "returns :ok if valid" do
      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", @example_timestamp)
        |> put_req_header("X-Slack-Signature", @example_signature)

      {body, timestamp, signature} = Request.read_and_parse(conn)

      assert :ok == Request.verify(body, timestamp, signature)
    end

    test "returns error if invalid" do
      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", @example_timestamp)
        |> put_req_header("X-Slack-Signature", @example_signature <> "a")

      {body, timestamp, signature} = Request.read_and_parse(conn)

      assert {:error, :invalid_signature} == Request.verify(body, timestamp, signature)
    end

    test "returns error if timestamp is old" do
      old_time =
        :os.system_time(:seconds)
        |> Kernel.-(60 * 5)
        |> to_string()

      conn =
        conn(:post, "/", @example_body)
        |> put_req_header("X-Slack-Request-Timestamp", old_time)
        |> put_req_header("X-Slack-Signature", @example_signature)

      {body, timestamp, signature} = Request.read_and_parse(conn)

      assert {:error, :timeout} == Request.verify(body, timestamp, signature)
    end
  end

  describe "calculate_hash/2" do
    test "returns correct example hash" do
      assert Request.calculate_hash(@example_body, @example_timestamp) == @example_signature
    end
  end
end
