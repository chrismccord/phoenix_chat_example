# Simple Chat Example
> Built with the [Phoenix Framework](https://github.com/phoenixframework/phoenix)

To start your new Phoenix application you have to:

1. Install dependencies with `mix deps.get`
2. Start Phoenix router with `mix phoenix.server`

Now you can visit `localhost:4000` from your browser.

## Live Demo
http://phoenixchat.herokuapp.com


## Example Code

#### JavaScript
```javascript
$(function(){
  var socket     = new Phoenix.Socket("/ws");
  var $status    = $("#status");
  var $messages  = $("#messages");
  var $input     = $("#message-input");
  var $username  = $("#username");
  var sanitize   = function(html){ return $("<div/>").text(html).html(); }

  var messageTemplate = function(message){
    var username = sanitize(message.username || "anonymous");
    var body     = sanitize(message.body);
    return("<p><a href='#'>[" + username + "]</a>&nbsp; " + body +"</p>");
  }

  socket.join("rooms:lobby", {}, function(chan){

    $input.off("keypress").on("keypress", function(e) {
      if (e.keyCode == 13) {
        chan.send("new:message", {username: $username.val(), body: $input.val()});
        $input.val("");
      }
    });

    chan.on("join", function(message){
      $status.text("joined");
    });

    chan.on("new:message", function(message){
      $messages.append(messageTemplate(message));
      scrollTo(0, document.body.scrollHeight);
    });

    chan.on("user:entered", function(msg){
      var username = sanitize(msg.username || "anonymous");
      $messages.append("<br/><i>[" + username + " entered]</i>");
    });
  });
});
 ```

#### Router
```elixir
defmodule Chat.Router do
  use Phoenix.Router

  socket "/ws", Chat do
    channel "rooms:*", RoomChannel
  end

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
end
```

#### Channel
```elixir
defmodule Chat.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("rooms:lobby", message, socket) do
    Logger.debug "JOIN #{socket.topic}"
    reply socket, "join", %{status: "connected"}
    broadcast! socket, "user:entered", %{user: message["user"]}
    {:ok, socket}
  end

  def join("rooms:" <> _private_subtopic, _message, socket) do
    {:error, :unauthorized, socket}
  end

  def leave(reason, socket) do
    Logger.error inspect(reason)
    {:ok, socket}
  end

  def handle_in("new:msg", message, socket) do
    broadcast socket, "new:msg", message
    {:ok, socket}
  end

  def handle_out(event, message, socket) do
    reply socket, event, message
    {:ok, socket}
  end
end
```
