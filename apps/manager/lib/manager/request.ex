defmodule Manager.Request do
  @enforce_keys [:response_url, :text, :user_id]
  defstruct [:response_url, :text, :user_id]
  @type t :: %__MODULE__{}
end
