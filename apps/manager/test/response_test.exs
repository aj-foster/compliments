defmodule Slack.ResponseTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Manager.Response
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

  describe "post_compliment/3" do
    test "posts a compliment" do
      response = {:ok, %HTTPoison.Response{body: "ok"}}

      with_mock HTTPoison, post: fn _url, _data, _headers -> response end do
        assert Response.post_compliment("John Doe", "Jane Doe", "Compliment") == :ok
        assert_called(HTTPoison.post(:_, :_, :_))
      end
    end

    test "handles a post error" do
      response = {:ok, %HTTPoison.Response{body: "channel_is_archived", status_code: 410}}

      with_mock HTTPoison, post: fn _url, _data, _headers -> response end do
        assert Response.post_compliment("John Doe", "Jane Doe", "Compliment") == :error
        assert_called(HTTPoison.post(:_, :_, :_))
      end
    end
  end

  describe "direct_message/2" do
    test "sends a message" do
      response = {:ok, %HTTPoison.Response{body: "{\"ok\": \"true\"}"}}

      with_mock HTTPoison, post: fn _url, _data, _headers -> response end do
        assert Response.direct_message("U01234567", "Compliment") == :ok
        assert_called(HTTPoison.post(:_, :_, :_))
      end
    end

    test "handles a post error" do
      response =
        {:ok, %HTTPoison.Response{body: "{\"ok\": \"false\", \"error\": \"channel_not_found\"}"}}

      with_mock HTTPoison, post: fn _url, _data, _headers -> response end do
        assert Response.direct_message("U01234567", "Compliment") == :error
        assert_called(HTTPoison.post(:_, :_, :_))
      end
    end
  end
end
