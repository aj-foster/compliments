defmodule Manager do
  @moduledoc """
  Validates and responds to compliment commands.
  """

  @doc """
  Accepts compliment command parameters, validates, and reacts.
  """
  def compliment(params) do
    with {:ok, params} <- parse_params(params),
         {:ok, %{}} <- parse_text(params) do
      :ok
    else
      {:error, :invalid_params} -> :error
      {:ok, :help} -> :ok
      {:error, :invalid_text} -> :error
    end
  end

  # Extract necessary information from Slack's request.
  defp parse_params(params) do
    with {:ok, "/compliment"} <- Map.fetch(params, "command"),
         {:ok, response_url} <- Map.fetch(params, "response_url"),
         {:ok, text} <- Map.fetch(params, "text"),
         {:ok, user_id} <- Map.fetch(params, "user_id") do
      {:ok, %{response_url: response_url, text: text, user_id: user_id}}
    else
      :error -> {:error, :invalid_params}
    end
  end

  # Extract necessary information from the /compliment [text].
  defp parse_text(params) do
    text =
      params
      |> Map.fetch!(:text)

    cond do
      String.match?(text, ~r/^\s*help/) ->
        respond_with_help(params)
        {:ok, :help}

      true ->
        respond_with_error(params)
        {:error, :invalid_text}
    end
  end

  defp respond_with_help(%{response_url: url}) do
    help = """
    {
      "response_type": "ephemeral",
      "text": "Example: `/compliment @JaneDoe Your work on our latest project was impressive...`"
    }
    """

    HTTPoison.post(url, help, [{"Content-Type", "application/json"}])
  end

  defp respond_with_error(%{response_url: url}) do
    help = """
    {
      "response_type": "ephemeral",
      "text": "Example: `/compliment @JaneDoe Your work on our latest project was impressive...`"
    }
    """

    HTTPoison.post(url, help, [{"Content-Type", "application/json"}])
  end
end
