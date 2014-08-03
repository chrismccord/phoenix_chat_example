use Mix.Config

config :phoenix, Chat.Router,
  port: System.get_env("PORT"),
  ssl: false,
  code_reload: false,
  cookies: true,
  session_key: "_chat_key",
  session_secret: "slkfja;lkfjsakl;fjaskl;fj;asklfjaskloiruoiwurowiruowoiuwfowiuwoi;jflsak;jf;saklfj;akslfjalksfjalsalskfjd"

config :phoenix, :logger,
  level: :error

