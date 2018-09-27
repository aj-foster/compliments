defmodule Manager.UserTest do
  use ExUnit.Case, async: false

  alias Manager.User
  import Mock

  @success_resp %HTTPoison.Response{
    body:
      "{\"ok\":true,\"user\":{\"id\":\"U01234567\",\"team_id\":\"T01234567\",\"name\":\"jane-doe\",\"deleted\":false,\"color\":\"5566ee\",\"real_name\":\"Jane Doe\",\"tz\":\"America\\/New_York\",\"tz_label\":\"Eastern Daylight Time\",\"tz_offset\":-14400,\"profile\":{\"title\":\"\",\"phone\":\"\",\"skype\":\"\",\"real_name\":\"Jane Doe\",\"real_name_normalized\":\"Jane Doe\",\"display_name\":\"jane-doe\",\"display_name_normalized\":\"jane-doe\",\"status_text\":\"\",\"status_emoji\":\"\",\"status_expiration\":0,\"avatar_hash\":\"0123456789ab\",\"image_original\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_original.jpg\",\"first_name\":\"Jane\",\"last_name\":\"Doe\",\"image_24\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_24.jpg\",\"image_32\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_32.jpg\",\"image_48\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_48.jpg\",\"image_72\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_72.jpg\",\"image_192\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_192.jpg\",\"image_512\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_512.jpg\",\"image_1024\":\"https:\\/\\/avatars.slack-edge.com\\/2016-01-20\\/01234567890_0123456789abcdef0123_512.jpg\",\"status_text_canonical\":\"\",\"team\":\"T01234567\",\"is_custom_image\":true},\"is_admin\":false,\"is_owner\":false,\"is_primary_owner\":false,\"is_restricted\":false,\"is_ultra_restricted\":false,\"is_bot\":false,\"is_app_user\":false,\"updated\":1522075873,\"has_2fa\":true}}",
    headers: [
      {"Content-Type", "application/json; charset=utf-8"},
      {"Transfer-Encoding", "chunked"},
      {"Connection", "keep-alive"},
      {"Date", "Thu, 27 Sep 2018 03:51:23 GMT"},
      {"Server", "Apache"},
      {"x-slack-router", "p"},
      {"X-Slack-Req-Id", "00000000-0000-4000-0000-000000000000"},
      {"X-OAuth-Scopes", "identify,commands,users:read"},
      {"X-Accepted-OAuth-Scopes", "users:read"},
      {"Expires", "Mon, 26 Jul 1997 05:00:00 GMT"},
      {"Cache-Control", "private, no-cache, no-store, must-revalidate"},
      {"Vary", "Accept-Encoding"},
      {"Pragma", "no-cache"},
      {"X-XSS-Protection", "0"},
      {"X-Content-Type-Options", "nosniff"},
      {"X-Slack-Exp", "1"},
      {"X-Slack-Backend", "h"},
      {"Referrer-Policy", "no-referrer"},
      {"Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload"},
      {"Access-Control-Allow-Origin", "*"},
      {"X-Via", "haproxy-www-6m47"},
      {"X-Cache", "Miss from cloudfront"},
      {"Via", "1.1 e180310aa2bd73460387710f5b74da16.cloudfront.net (CloudFront)"},
      {"X-Amz-Cf-Id", "UE9MaGd8vSH9hZpiHA_yURCaZumffIYylp1dPczfgqR2Rg6gi1DfhA=="}
    ],
    request_url: "https://slack.com/api/users.info?user=U01234567",
    status_code: 200
  }

  @error_resp %HTTPoison.Response{
    body: "{\"ok\":false,\"error\":\"not_authed\"}",
    headers: [
      {"Content-Type", "application/json; charset=utf-8"},
      {"Transfer-Encoding", "chunked"},
      {"Connection", "keep-alive"},
      {"Date", "Thu, 27 Sep 2018 03:49:19 GMT"},
      {"Server", "Apache"},
      {"Vary", "Accept-Encoding"},
      {"X-Content-Type-Options", "nosniff"},
      {"X-XSS-Protection", "0"},
      {"X-Slack-Req-Id", "00000000-0000-4000-0000-000000000000"},
      {"X-Accepted-OAuth-Scopes", "users:read"},
      {"Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload"},
      {"Referrer-Policy", "no-referrer"},
      {"x-slack-router", "p"},
      {"X-Slack-Backend", "h"},
      {"X-Slack-Exp", "1"},
      {"Access-Control-Allow-Origin", "*"},
      {"X-Via", "haproxy-www-7xdi"},
      {"X-Cache", "Miss from cloudfront"},
      {"Via", "1.1 2ee14cac814192f87d53ae087cc20595.cloudfront.net (CloudFront)"},
      {"X-Amz-Cf-Id", "So55EZzJAekmDYabQcSNO4kWNQDC_s7JeKh1QnWCVu6JgbTwJrt0Tg=="}
    ],
    request_url: "https://slack.com/api/users.info?user=U01234567",
    status_code: 200
  }

  describe "get_name/1" do
    test "returns name" do
      with_mock HTTPoison, get: fn _url, _headers -> {:ok, @success_resp} end do
        User.clear_cache()
        name = User.get_name("U01234567")

        assert name == "Jane Doe"
      end
    end

    test "caches missed name" do
      with_mock HTTPoison, get: fn _url, _headers -> {:ok, @success_resp} end do
        User.clear_cache()
        User.get_name("U01234567")

        assert [{"U01234567", "Jane Doe", time}] = :ets.lookup(:user_cache, "U01234567")
        assert abs(:os.system_time(:seconds) + 60 * 60 * 24 * 7 - time) < 3600
      end
    end

    test "returns error when appropriate" do
      with_mock HTTPoison, get: fn _url, _headers -> {:ok, @error_resp} end do
        User.clear_cache()
        name = User.get_name("U01234567")

        assert name == :error
      end
    end
  end
end
