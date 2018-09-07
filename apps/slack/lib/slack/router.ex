defmodule Slack.Router do
  use Plug.Router
  use Plug.Debugger, otp_app: :slack

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  # Informational endpoint, for someone who finds this application.
  get "/" do
    send_resp(conn, 200, """
    This application provides a `/compliment` command for Slack workspaces.

    If you have questions, please contact AJ Foster.
    """)
  end

  # Health check endpoint, to monitor uptime.
  get "/health" do
    send_resp(conn, 200, "OK")
  end

    send_resp(conn, 200, "Success")
  end

  # Catch-all for other requests.
  match _ do
    send_resp(conn, 200, "The command could not be completed (error: invalid route)")
  end
end
