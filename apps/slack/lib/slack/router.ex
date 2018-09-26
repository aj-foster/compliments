defmodule Slack.Router do
  use Plug.Router
  use Plug.Debugger, otp_app: :slack

  alias Slack.Request

  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    body_reader: {Slack.Reader, :read_body, []},
    json_decoder: Poison
  )

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

  # Incoming Slack requests.
  post "/" do
    with {body, timestamp, signature} <- Request.read_and_parse(conn),
         :ok <- Request.verify(body, timestamp, signature) do
      Manager.compliment(conn.params)
      send_resp(conn, 200, "")
    else
      {:error, :missing_header} ->
        send_resp(conn, 200, "The command could not be completed (error: missing header)")

      {:error, :invalid_signature} ->
        send_resp(conn, 200, "The command could not be completed (error: invalid signature)")

      {:error, reason} ->
        send_resp(conn, 200, "The command could not be completed (error: #{to_string(reason)})")
    end
  end

  # Catch-all for other requests.
  match _ do
    send_resp(conn, 200, "The command could not be completed (error: invalid route)")
  end
end
