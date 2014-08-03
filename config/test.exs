use Mix.Config

config :phoenix, Chat.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  code_reload: false,
  cookies: true,
  consider_all_requests_local: true,
  session_key: "_chat_key",
  session_secret: "slkfja;lkfjsakl;fjaskl;fj;asklfjaskloiruoiwurowiruowoiuwfowiuwoi;jflsak;jf;saklfj;akslfjalksfjalsalskfjd"

config :phoenix, :logger,
  level: :debug


