defmodule Manager.User do
  defstruct [:name, :id]
  @type t :: %__MODULE__{}

  def init() do
    :ets.info(:user_cache)
    |> case do
      :undefined ->
        :ets.new(:user_cache, [:set, :named_table])
        :ok

      _ ->
        :ok
    end
  end

  @spec get_name(binary()) :: {:ok, binary()} | :error
  def get_name(user_id) do
    case get_cached_name(user_id) do
      name when is_binary(name) ->
        name

      _ ->
        name = get_name_from_api(user_id)
        cache_name(user_id, name)

        name
    end
  end

  @spec get_cached_name(binary()) :: binary() | :cache_miss
  defp get_cached_name(user_id) do
    with [{^user_id, name, expiration}] <- :ets.lookup(:user_cache, user_id),
         false <- past_expiration?(expiration) do
      name
    else
      _ -> :cache_miss
    end
  end

  @spec get_name_from_api(binary()) :: binary() | :error
  def get_name_from_api(user_id) do
    url = "https://slack.com/api/users.info"
    params = "user=#{user_id}"
    token = Application.get_env(:slack, :oauth_token)

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Bearer #{token}"}
    ]

    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get("#{url}?#{params}", headers),
         {:ok, data} <- Poison.decode(body),
         %{"user" => user} <- data,
         %{"profile" => profile} <- user,
         %{"real_name" => name} <- profile do
      name
    else
      _ -> :error
    end
  end

  defp cache_name(user_id, name) do
    case name do
      name when is_binary(name) ->
        # 1 week expiration
        expiration = :os.system_time(:seconds) + 604_800
        :ets.insert(:user_cache, {user_id, name, expiration})

      _ ->
        nil
    end

    name
  end

  defp past_expiration?(time) do
    time > :os.system_time(:seconds)
  end
end
