defmodule Manager.User do
  @moduledoc """
  Match user IDs to other user information, such as a real name.

  This module caches user information using an in-memory table with an
  expiration field.
  """
  use GenServer

  # Time-To-Live for cached records
  @expiration 604_800

  ##############
  # Client API #
  ##############

  @doc """
  Remove all users from the cache.
  """
  @spec clear_cache() :: :ok
  def clear_cache() do
    GenServer.call(__MODULE__, :clear_cache)
  end

  @doc """
  Retrieve the real name of a user.
  """
  @spec get_name(binary()) :: {:ok, binary()} | :error
  def get_name(user_id) do
    GenServer.call(__MODULE__, {:get_name, user_id})
  end

  ###########
  # Helpers #
  ###########

  # Look for a name in the cache.
  @spec get_cached_name(atom(), binary()) :: binary() | :cache_miss
  defp get_cached_name(table, user_id) do
    with [{^user_id, name, expiration}] <- :ets.lookup(table, user_id),
         false <- past_expiration?(expiration) do
      {:ok, name}
    else
      _ -> {:error, :cache_miss}
    end
  end

  # Retrieve the user's name from the Slack API.
  @spec get_name_from_api(binary()) :: binary() | :error
  defp get_name_from_api(user_id) do
    url = "https://slack.com/api/users.info"
    params = "user=#{user_id}"
    token = Application.get_env(:manager, :oauth_token)

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Bearer #{token}"}
    ]

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get("#{url}?#{params}", headers),
         {:ok, data} <- Poison.decode(body),
         %{"user" => user} <- data,
         %{"profile" => profile} <- user,
         %{"real_name" => name} <- profile do
      {:ok, name}
    else
      _ -> :error
    end
  end

  @spec cache_name(atom(), binary(), binary()) :: :ok | :error
  defp cache_name(table, user_id, name) do
    case name do
      name when is_binary(name) ->
        # 1 week expiration
        expiration = :os.system_time(:seconds) + @expiration
        :ets.insert(table, {user_id, name, expiration})

        :ok

      _ ->
        :error
    end
  end

  defp past_expiration?(time) do
    time > :os.system_time(:seconds)
  end

  ##############
  # Server API #
  ##############

  @doc """
  Starts a GenServer with the Module's name.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  GenServer callback. Creates or finds an ETS table for caching.
  """
  @impl GenServer
  def init(_) do
    with :undefined <- :ets.info(:user_cache),
         table <- :ets.new(:user_cache, [:set, :named_table]) do
      {:ok, table}
    else
      [{:name, :user_cache} | _] -> {:ok, :user_cache}
      _ -> {:stop, :ets_error}
    end
  end

  @impl GenServer
  def handle_call({:get_name, user_id}, _from, table) do
    with {:error, :cache_miss} <- get_cached_name(table, user_id),
         {:ok, name} <- get_name_from_api(user_id) do
      cache_name(table, user_id, name)
      {:reply, {:ok, name}, table}
    else
      {:ok, name} ->
        {:reply, {:ok, name}, table}

      :error ->
        {:reply, :error, table}
    end
  end

  @impl GenServer
  def handle_call(:clear_cache, _from, table) do
    :ets.delete_all_objects(table)
    {:reply, :ok, table}
  end
end
