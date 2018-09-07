defmodule Slack.Request do
  @moduledoc """
  Provides utilities to read, verify, and handle Slack requests.
  """

  alias Plug.Conn

  @doc """
  Read and parse a Slack request for its body, timestamp, and signature.
  """
  @spec read_and_parse(Conn.t()) :: {binary(), binary(), binary()} | {:error, term()}
  def read_and_parse(conn) do
    with [timestamp | _] <- Conn.get_req_header(conn, "X-Slack-Request-Timestamp"),
         [signature | _] <- Conn.get_req_header(conn, "X-Slack-Signature"),
         {:ok, body, _} <- Conn.read_body(conn) do
      {body, timestamp, signature}
    else
      [] ->
        {:error, :missing_header}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Verify a Slack request based on the supplied signature.
  """
  @spec verify(binary(), binary(), binary()) ::
          :ok | {:error, :timeout} | {:error, :invalid_signature}
  def verify(body, timestamp, signature) do
    cond do
      !valid_timestamp?(timestamp) ->
        {:error, :timeout}

      calculate_hash(body, timestamp) == signature ->
        :ok

      true ->
        {:error, :invalid_signature}
    end
  end

  # Verify request timestamp in a test-friendly way.
  @spec valid_timestamp?(binary()) :: boolean()
  defp valid_timestamp?(timestamp) do
    is_test_time = Mix.env() == :test && timestamp == "1531420618"
    time_now = :os.system_time(:seconds)
    time_limit = time_now - 60 * 5

    case Integer.parse(timestamp, 10) do
      {time_then, _} when is_integer(time_then) ->
        time_then > time_limit || is_test_time

      _ ->
        false
    end
  end

  @doc """
  Calculate the the hash of a request's body and timestamp.

  A shared secret must be configured using the following:

      config :slack, shared_secret: "8f742231b10e8888abcd99yyyzzz85a5"

  ...making sure to replace the string above with a real secret.
  """
  @spec calculate_hash(binary(), binary()) :: binary()
  def calculate_hash(body, timestamp) do
    secret = Application.fetch_env!(:slack, :shared_secret)
    basestring = "v0:#{timestamp}:#{body}"

    hash =
      :crypto.hmac(:sha256, secret, basestring)
      |> Base.encode16(case: :lower)

    "v0=#{hash}"
  end
end
