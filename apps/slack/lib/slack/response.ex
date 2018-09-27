defmodule Slack.Response do
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
end
