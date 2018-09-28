defmodule Manager.Request do
  @enforce_keys [:response_url, :text, :from]
  defstruct [:response_url, :text, :from, :to, :compliment]
  @type t :: %__MODULE__{}
end
