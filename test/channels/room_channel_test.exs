defmodule Chat.RoomChannelTest do
  use Chat.ChannelCase
  alias Chat.RoomChannel

  setup do
    {:ok, _, socket} = subscribe_and_join(socket(), RoomChannel, "rooms:lobby", %{"user" => "Bob"})
    {:ok, socket: socket}
  end

  test "join subtopic other than lobby", %{socket: _socket} do
    ref = subscribe_and_join(socket(), RoomChannel, "rooms:other")
    assert {:error, %{reason: "unauthorized"}} = ref
  end

  test "join rooms:lobby", %{socket: _socket} do
    assert_broadcast("user:entered", %{user: "Bob"})
    assert_push("join", %{status: "connected"})
  end

  test "ping channel", %{socket: socket} do
    send(socket.channel_pid, :ping)
    assert_push("new:msg", %{user: "SYSTEM", body: "ping"})
  end

  test "handle new:message", %{socket: socket} do
    ref = push(socket, "new:msg", %{"user" => "Bob", "body" => "Hello World"})
    socket = Phoenix.Channel.Server.socket(socket.channel_pid) #retrieve the updated socket

    assert socket.assigns[:user] == "Bob"
    assert_reply(ref, :ok, %{msg: "Hello World"})
    assert_broadcast("new:msg", %{user: "Bob", body: "Hello World"}, socket)
  end

  test "leaving channel", %{socket: socket} do
    Process.unlink(socket.channel_pid)
    ref = leave(socket)
    assert_reply(ref, :ok)
  end
end
