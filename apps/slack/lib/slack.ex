defmodule Slack do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:slack, :port, 4000)

    children = [
      Plug.Adapters.Cowboy2.child_spec(scheme: :http, plug: Slack.Router, options: [port: port])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
