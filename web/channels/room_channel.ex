defmodule Chat.RoomChannel do
  use Phoenix.Channel
  require Logger

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  {:ok, socket} to authorize subscription for channel for requested topic

  {:error, socket, reason} to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join("rooms:lobby", message, socket) do
    Logger.debug "JOIN #{socket.topic}"
    reply socket, "join", %{status: "connected"}
    broadcast! socket, "user:entered", %{user: message["user"]}
    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, socket) do
    {:error, socket, :unauthorized}
  end

  def leave(reason, socket) do
    Logger.error inspect(reason)
    {:ok, socket}
  end

  def handle_in("new:msg", message, socket) do
    broadcast! socket, "new:msg", message
    {:ok, socket}
  end

  def handle_out(event, message, socket) do
    reply socket, event, message
    {:ok, socket}
  end
end
