defmodule Slack.ResponseTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Slack.Response
  import Mock

  @response_url "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX"

  describe "respond/3" do
    test "posts ephemeral response" do
      with_mock HTTPoison, post: fn _url, data, _headers -> {:ok, data} end do
        {:ok, body} = Response.respond(@response_url, "A message")

        assert called(HTTPoison.post(@response_url, :_, :_))
        assert body =~ "A message"
        assert body =~ "ephemeral"
      end
    end

    test "posts in-channel response" do
      with_mock HTTPoison, post: fn _url, data, _headers -> {:ok, data} end do
        {:ok, body} = Response.respond(@response_url, "A message", in_channel: true)

        assert called(HTTPoison.post(@response_url, :_, :_))
        assert body =~ "A message"
        assert body =~ "in_channel"
      end
    end

    test "returns error for invalid URL" do
      with_mock HTTPoison, post: fn _url, data, _headers -> {:ok, data} end do
        assert Response.respond("https://example.com", "A message") == {:error, :invalid_url}

        refute called(HTTPoison.post(@response_url, :_, :_))
      end
    end
  end
end
