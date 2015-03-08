use Mix.Config

config :chat, Chat.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  cache_static_lookup: false,
  pubsub: [adapter: Phoenix.PubSub.PG2]

# Enables code reloading for development
config :phoenix, :code_reloader, true
