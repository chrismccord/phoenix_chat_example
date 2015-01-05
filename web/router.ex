defmodule Chat.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", Chat do
    pipe_through :browser

    get "/", PageController, :index
  end

  channel "rooms", Chat.RoomChannel
end
