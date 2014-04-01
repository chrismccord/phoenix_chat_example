defmodule Chat.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  plug Plug.Static, at: "/static", from: :chat
  get "/", Chat.Controllers.Pages, :index, as: :page

  channel "messages", Chat.Channels.Messages
end
