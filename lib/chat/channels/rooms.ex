defmodule Chat.Channels.Rooms do
  use Phoenix.Channel

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  {:ok, socket} to authorize subscription for channel for requested topic

  {:error, socket, reason} to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join(socket, message) do
    IO.puts "JOIN #{socket.channel}:#{socket.topic}"
    reply socket, "join", status: "connected"
    broadcast socket, "user:entered", username: message["username"]
    {:ok, socket}
  end

  def event("new:message", socket, message) do
    broadcast socket, "new:message", message
    {:ok, socket}
  end
end



