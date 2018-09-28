defmodule ManagerTest do
  use ExUnit.Case

  alias Manager.{Response, User}
  import Mock

  @help_request %{
    "command" => "/compliment",
    "response_url" =>
      "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX",
    "team_id" => "T01234567",
    "text" => "help",
    "user_id" => "U01234567"
  }

  @error_request %{
    "command" => "/compliment",
    "response_url" =>
      "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX",
    "team_id" => "T01234567",
    "text" => "error",
    "user_id" => "U01234567"
  }

  @normal_request %{
    "command" => "/compliment",
    "response_url" =>
      "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX",
    "team_id" => "T01234567",
    "text" => "<@U76543210> Your work on our latest project was impressive...",
    "user_id" => "U01234567"
  }

  @odd_request %{
    "command" => "/compliment",
    "response_url" =>
      "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX",
    "team_id" => "T01234567",
    "text" =>
      "  <@U76543210|some-name>  Msg <w> weird <@UABCDEFGH|name> ! @ # $ % ^ & * ( ) chars\n\n\t etc",
    "user_id" => "U01234567"
  }

  @request_with_mention %{
    "command" => "/compliment",
    "response_url" =>
      "https://hooks.slack.com/commands/T01234567/012345678901/AbcDEfGHiJklmNOpqeSTUVWX",
    "team_id" => "T01234567",
    "text" => "<@U76543210|some-name> You and <@UABCDEFGH|name> rock!",
    "user_id" => "U01234567"
  }

  describe "compliment/1" do
    test "sends help message" do
      with_mock Response, respond: fn _url, _text -> {:ok, %HTTPoison.Response{}} end do
        Manager.compliment(@help_request)

        assert called(Response.respond(:_, :_))
      end
    end

    test "sends error message" do
      with_mock Response, respond: fn _url, _text -> {:ok, %HTTPoison.Response{}} end do
        Manager.compliment(@error_request)

        assert called(Response.respond(:_, :_))
      end
    end

    test "handles normal request" do
      with_mock User, get_name: fn _user_id -> {:ok, "Jane Doe"} end do
        with_mock Response,
          respond: fn _url, _text -> {:ok, %HTTPoison.Response{}} end,
          post_compliment: fn _from, _to, _compliment -> :ok end,
          direct_message: fn _user_id, _message -> :ok end do
          Manager.compliment(@normal_request)

          assert_called(Response.respond(:_, :_))
          assert_called(Response.post_compliment(:_, :_, :_))
          assert_called(Response.direct_message(:_, :_))
        end
      end
    end

    test "handles odd request" do
      with_mock User, get_name: fn _user_id -> {:ok, "Jane Doe"} end do
        with_mock Response,
          respond: fn _url, _text -> {:ok, %HTTPoison.Response{}} end,
          post_compliment: fn _from, _to, _compliment -> :ok end,
          direct_message: fn _user_id, _message -> :ok end do
          Manager.compliment(@odd_request)

          assert_called(Response.respond(:_, :_))
          assert_called(Response.post_compliment(:_, :_, :_))
          assert_called(Response.direct_message(:_, :_))
        end
      end
    end

    test "handles request with a mention" do
      with_mock User, get_name: fn _user_id -> {:ok, "Jane Doe"} end do
        with_mock Response,
          respond: fn _url, _text -> {:ok, %HTTPoison.Response{}} end,
          post_compliment: fn _from, _to, _compliment -> :ok end,
          direct_message: fn _user_id, _message -> :ok end do
          Manager.compliment(@request_with_mention)

          assert_called(Response.respond(:_, :_))
          assert_called(Response.post_compliment(:_, :_, "You and <@UABCDEFGH|name> rock!"))
          assert_called(Response.direct_message(:_, :_))
        end
      end
    end
  end
end
