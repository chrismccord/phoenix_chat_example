defmodule Chat.Channels.Messages do
  use Phoenix.Channel

  def join(socket, message) do
    IO.puts "JOIN"
    reply socket, "join", status: "connected"
    broadcast socket, "user:entered", username: "anonymous"
    {:ok, socket}
  end

  def event("new", socket, message) do
    broadcast socket, "new", message
    {:ok, socket}
  end
end



