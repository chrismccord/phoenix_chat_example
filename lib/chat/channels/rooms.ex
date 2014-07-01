defmodule Chat.Channels.Rooms do
  use Phoenix.Channel

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  {:ok, socket} to authorize subscription for channel for requested topic

  {:error, socket, reason} to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join(socket, "lobby", message) do
    IO.puts "JOIN #{socket.channel}:#{socket.topic}"
    reply socket, "join", %{status: "connected"}
    broadcast socket, "user:entered", %{username: message["username"]}
    {:ok, socket}
  end

  def join(socket, _private_topic, _message) do
    {:error, socket, :unauthorized}
  end

  def event(socket, "new:message", message) do
    broadcast socket, "new:message", message
    socket
  end
end



