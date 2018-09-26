defmodule ManagerTest do
  use ExUnit.Case

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

  describe "compliment/1" do
    test "sends help message" do
      with_mock HTTPoison, post: fn _url, _data, _headers -> {:ok, %HTTPoison.Response{}} end do
        Manager.compliment(@help_request)

        assert called(HTTPoison.post(:_, :_, :_))
      end
    end

    test "sends error message" do
      with_mock HTTPoison, post: fn _url, _data, _headers -> {:ok, %HTTPoison.Response{}} end do
        Manager.compliment(@error_request)

        assert called(HTTPoison.post(:_, :_, :_))
      end
    end
  end
end
