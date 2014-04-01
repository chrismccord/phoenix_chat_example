defmodule Chat.Config.Test do
  use Chat.Config

  config :router, port: 4001,
                  ssl: false

  config :plugs, code_reload: true

  config :logger, level: :debug
end


