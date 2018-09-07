defmodule Slack do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Slack.Router, options: [port: 4000])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
