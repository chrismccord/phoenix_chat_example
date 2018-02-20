defmodule ChatWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  channel "rooms:*", ChatWeb.RoomChannel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
