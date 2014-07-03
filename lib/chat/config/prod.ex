defmodule Chat.Config.Prod do
  use Chat.Config

  config :router, port: System.get_env("PORT"),
                  ssl: false

  config :plugs, code_reload: false

  config :logger, level: :error
end


