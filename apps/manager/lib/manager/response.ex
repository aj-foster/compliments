defmodule Manager.Response do
  @doc """
  Use the given response URL to post a message.

  Available options:

    * `in_channel`: set to `true` to have response visible to all channel members
  """
  @spec respond(binary(), binary(), Keyword.t()) ::
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()}
          | {:error, :invalid_url}
  def respond(url, text, opts \\ [])

  def respond("https://hooks.slack.com/commands/" <> _ = url, text, opts) do
    response_type =
      case opts[:in_channel] do
        true -> "in_channel"
        _ -> "ephemeral"
      end

    body = """
    {
      "response_type": "#{response_type}",
      "text": "#{text}"
    }
    """

    HTTPoison.post(url, body, [{"Content-Type", "application/json"}])
  end

  def respond(_url, _text, _opts), do: {:error, :invalid_url}

  @doc """
  Send a compliment message via Slack Incoming Webhook.

  The channel to which the compliment is posted will be determined by
  the user installing the application. This request requires a webhook
  URL, configured via `config :slack, webhook: "..."`.
  """
  @spec post_compliment(binary(), binary(), binary()) :: :ok | :error
  def post_compliment(from, to, compliment) do
    body = %{
      "text" => "*#{from}* complimented *#{to}*:",
      "attachments" => [
        %{"text" => compliment, "color" => "#F15B51"}
      ]
    }

    url = Application.get_env(:slack, :webhook)
    {:ok, body} = Poison.encode(body)
    headers = [{"Content-Type", "application/json"}]

    with {:ok, response} <- HTTPoison.post(url, body, headers),
         "ok" <- response.body do
      :ok
    else
      _ -> :error
    end
  end

  # def post_compliment(from, to, message) do
  #   url = "https://slack.com/api/chat.postMessage"
  #   token = Application.get_env(:slack, :oauth_token)

  #   body = %{
  #     # "channel" => "??????"
  #     "text" => "*#{from}* complimented *#{to}*:",
  #     "attachments" => [
  #       %{"text" => message, "color" => "#F15B51"}
  #     ]
  #   }

  #   headers = [
  #     {"Content-Type", "application/json"},
  #     {"Authorization", "Bearer #{token}"}
  #   ]

  #   with {:ok, body} <- Poison.encode(body),
  #        {:ok, response} <- HTTPoison.post(url, body, headers),
  #        {:ok, resp_body} <- Poison.decode(response.body),
  #        %{"ok" => "true"} <- response,
  #        %{"channel" => channel} <- response do
  #     {:ok, channel}
  #   else
  #     x -> IO.inspect(x, label: "ERROR")
  #   end
  # end

  @doc """
  Send a direct message to a Slack user.

  We intend this to be used as a notification to the recipient
  of a compliment. This requires the `chat:write:bot` permission
  and will post all messages as the application.
  """
  @spec direct_message(binary(), binary()) :: :ok | :error
  def direct_message(user_id, message) do
    url = "https://slack.com/api/chat.postMessage"
    token = Application.get_env(:slack, :oauth_token)

    body = %{
      "channel" => user_id,
      "text" => message
    }

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"}
    ]

    with {:ok, body} <- Poison.encode(body),
         {:ok, response} <- HTTPoison.post(url, body, headers),
         {:ok, resp_body} <- Poison.decode(response.body),
         %{"ok" => "true"} <- resp_body do
      :ok
    else
      _ -> :error
    end
  end
end
