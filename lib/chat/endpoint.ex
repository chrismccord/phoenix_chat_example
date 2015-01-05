defmodule Chat.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat

  plug Plug.Static,
    at: "/", from: :chat

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_chat_key",
    signing_salt: "P2a5el37",
    encryption_salt: "H45GTWRf"

  plug :router, Chat.Router
end
