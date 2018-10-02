use Mix.Config

config :slack,
  port: 4000,
  shared_secret: System.get_env("SLACK_SHARED_SECRET")

config :manager,
  oauth_token: System.get_env("SLACK_OAUTH_TOKEN"),
  webhook: System.get_env("SLACK_WEBHOOK")
