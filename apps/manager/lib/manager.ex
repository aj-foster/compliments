defmodule Manager do
  @moduledoc """
  Validates and responds to compliment commands.
  """
  use GenServer

  @doc """
  Handle an incoming compliment command.

  This runner simply serializes the incoming request using a GenServer.
  """
  @spec run(map()) :: :ok
  def run(params) do
    GenServer.cast(__MODULE__, {:compliment, params})
  end

  @doc """
  Accepts compliment command parameters, validates, and reacts.
  """
  @spec compliment(map()) :: :ok | :error
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
  @spec parse_params(map()) :: {:ok, map()} | {:error, :invalid_params}
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
  @spec parse_text(map()) :: {:ok, map()} | {:ok, :help} | {:error, :invalid_text}
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

  @spec respond_with_help(%{response_url: binary()}) :: {:ok, HTTPoison.Response.t()}
  defp respond_with_help(%{response_url: url}) do
    help = """
    {
      "response_type": "ephemeral",
      "text": "Example: `/compliment @JaneDoe Your work on our latest project was impressive...`"
    }
    """

    HTTPoison.post(url, help, [{"Content-Type", "application/json"}])
  end

  @spec respond_with_error(%{response_url: binary()}) :: {:ok, HTTPoison.Response.t()}
  defp respond_with_error(%{response_url: url}) do
    help = """
    {
      "response_type": "ephemeral",
      "text": "Example: `/compliment @JaneDoe Your work on our latest project was impressive...`"
    }
    """

    HTTPoison.post(url, help, [{"Content-Type", "application/json"}])
  end

  # Start a GenServer with the Module's name.
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # Start a GenServer with no state.
  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  # Call compliment/1 to complete serialized requests.
  @impl GenServer
  def handle_cast({:compliment, params}, state) do
    compliment(params)
    {:noreply, state}
  end
end
