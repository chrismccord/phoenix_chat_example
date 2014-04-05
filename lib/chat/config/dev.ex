defmodule Chat.Config.Dev do
  use Chat.Config

  config :router, port: System.get_env("PORT") || "4000",
                  ssl: false

  config :plugs, code_reload: true

  config :logger, level: :debug
end


