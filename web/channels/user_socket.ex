defmodule Chat.UserSocket do
  use Phoenix.Socket

  channel "rooms:*", Chat.RoomChannel
  channel "__absinthe__:*", Absinthe.Phoenix.Channel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    opts = [
      context: %{},
      jump_phases: false,
    ]

    socket =
      socket
      |> assign(:absinthe, %{schema_mod: Chat.Schema, opts: opts})

    {:ok, socket}
  end

  def id(_socket), do: nil
end
