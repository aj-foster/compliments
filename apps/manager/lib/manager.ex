defmodule Manager do
  @moduledoc """
  Validates and responds to compliment commands.
  """
  use GenServer

  alias Manager.{Request, Response, User}

  @compliment_regex ~r/^\s*\<@(?<user>U[0-9A-Z]+)(\|[^>]*)?\>\s+(?<compliment>[\s\S]*)$/

  @help_text """
  Example: `/compliment @JaneDoe Your work on our latest project was impressive...`
  """

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
    with {:ok, %Request{} = request} <- parse_params(params),
         {:ok, %Request{} = request} <- parse_text(request),
         {:ok, compliment} <- Map.fetch(request, :compliment),
         {:ok, sender} <- User.get_name(request.from),
         {:ok, recipient} <- User.get_name(request.to),
         :ok <- Response.post_compliment(sender, recipient, compliment) do
      Response.respond(
        request.response_url,
        "Thank you for sharing your appreciation! Your compliment has been posted."
      )

      Response.direct_message(
        request.to,
        "#{sender} gave you a compliment in the compliments channel. Yay!"
      )

      :ok
    else
      {:ok, :help} ->
        Response.respond(params["response_url"], @help_text)
        :ok

      {:error, :invalid_text} ->
        Response.respond(params["response_url"], """
        We couldn't interpret your compliment. Please ensure it follows this example:

        ```
        /compliment @JaneDoe Your work on our latest project was impressive...
        ```
        """)

        :error

      {:error, :invalid_params} ->
        Response.respond(
          params["response_url"],
          "An error occurred while posting your compliment (`invalid_params`)"
        )

        :error

      :error ->
        Response.respond(
          params["response_url"],
          "An error occurred while posting your compliment (`general error`)"
        )

        :error
    end
  end

  # Extract necessary information from Slack's request.
  @spec parse_params(map()) :: {:ok, Request.t()} | {:error, :invalid_params}
  defp parse_params(params) do
    with {:ok, "/compliment"} <- Map.fetch(params, "command"),
         {:ok, response_url} <- Map.fetch(params, "response_url"),
         {:ok, text} <- Map.fetch(params, "text"),
         {:ok, user_id} <- Map.fetch(params, "user_id") do
      {:ok, %Request{response_url: response_url, text: text, from: user_id}}
    else
      :error -> {:error, :invalid_params}
    end
  end

  # Extract necessary information from the /compliment [text].
  @spec parse_text(Request.t()) :: {:ok, Request.t()} | {:ok, :help} | {:error, :invalid_text}
  defp parse_text(%{text: text} = params) do
    matches = Regex.named_captures(@compliment_regex, text, capture: :first)

    cond do
      String.match?(text, ~r/^\s*help/) ->
        {:ok, :help}

      is_map(matches) ->
        {:ok, to} = Map.fetch(matches, "user")
        {:ok, compliment} = Map.fetch(matches, "compliment")

        {:ok, %Request{params | to: to, compliment: compliment}}

      true ->
        {:error, :invalid_text}
    end
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
