# Chat

To start your new Phoenix application you have to:

1. Install dependencies with `mix deps.get`
2. Start Phoenix router with `mix run -e 'Chat.Config.Router.start' --no-halt mix.exs`

Now you can visit `localhost:4000` from your browser.


## Example

#### JavaScript
```javascript
var socket     = new Phoenix.Socket("ws://localhost:4000/ws");
var $status    = $("#status");
var $messages  = $("#messages");
var $input     = $("#message-input");

socket.join("messages", "global", {}, function(chan){

  $input.off("keypress").on("keypress", function(e) {
    if (e.keyCode == 13) {
      chan.send("new", {body: $input.val()});
      $input.val("");
    }
  });

  chan.on("join", function(message){
    $status.text("joined");
  });

  chan.on("new", function(message){
    $messages.append("<br/>" + message.body);
  });

  chan.on("user:entered", function(msg){
    $messages.append("<br/><i>[" + msg.username + " entered]</i>");
  });
});
```

#### Router
```elixir
defmodule Chat.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  plug Plug.Static, at: "/static", from: :chat
  get "/", Chat.Controllers.Pages, :index, as: :page

  channel "messages", Chat.Channels.Messages
end
```

#### Channel
```elixir
defmodule Chat.Channels.Messages do
  use Phoenix.Channel

  def join(socket, message) do
    IO.puts "JOIN #{socket.channel}:#{socket.topic}"
    reply socket, "join", status: "connected"
    broadcast socket, "user:entered", username: "anonymous"
    {:ok, socket}
  end

  def event("new", socket, message) do
    broadcast socket, "new", message
    {:ok, socket}
  end
end
```
