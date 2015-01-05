use Mix.Config

config :chat, Chat.Endpoint,
  http: [port: System.get_env("PORT") || 4001]
