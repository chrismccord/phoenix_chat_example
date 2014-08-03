defmodule Chat.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  get "/", Chat.PageController, :index, as: :page

  channel "rooms", Chat.RoomChannel
end
