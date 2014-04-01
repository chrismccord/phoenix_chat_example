defmodule Chat.Config do
  use Phoenix.Config.App

  config :router, port: System.get_env("PORT")

  config :plugs, code_reload: false

  config :logger, level: :error
end


