defmodule Manager.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Manager,
        start: {Manager, :start_link, []}
      },
      %{
        id: Manager.User,
        start: {Manager.User, :start_link, []}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
