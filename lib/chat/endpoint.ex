defmodule Chat.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :chat,
    only: ~w(css images js favicon.ico robots.txt)

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.LiveReloader
  end


  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_chat_key",
    signing_salt: "LH6XmqGb",
    encryption_salt: "CIPZg4Qo"

  plug :router, Chat.Router
end
