defmodule Slack.Router do
  use Plug.Router
  use Plug.Debugger, otp_app: :slack

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  post "/webhook" do
    send_resp(conn, 200, "Success")
  end

  match _ do
    send_resp(conn, 500, "Error")
  end
end
