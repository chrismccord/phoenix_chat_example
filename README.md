# Simple Chat Example
> Built with the [Phoenix Framework](https://github.com/phoenixframework/phoenix)

To start your new Phoenix application you have to:

1. Clone this repo, then cd to the new directory
2. Install dependencies with `mix deps.get`
3. (optional) Install npm dependencies to customize the ES6 js/Sass `npm install`
4. Start Phoenix router with `mix phoenix.server`

Now you can visit `localhost:4000` from your browser.

## Live Demo
http://phoenixchat.herokuapp.com


## Example Code

#### JavaScript
```javascript
import {Socket, LongPoller} from "phoenix"

class App {

  static init(){
    var socket  = new Socket("ws://" + location.host +  "/ws", {transport: LongPoller})
    // var socket     = new Socket("ws://" + location.host +  "/ws")
    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    socket.join("rooms:lobby", {}, chan => {
      $input.off("keypress").on("keypress", e => {
        if (e.keyCode == 13) {
          chan.send("new:msg", {user: $username.val(), body: $input.val()})
          $input.val("")
        }
      })

      chan.on("join", msg => {
        $messages.append("<br/><i>[You are now connected]</i>")
      })

      chan.on("new:msg", msg => {
        $messages.append(this.messageTemplate(msg))
        scrollTo(0, document.body.scrollHeight)
      })

      chan.on("user:entered", msg => {
        var username = this.sanitize(msg.user || "anonymous")
        $messages.append(`<br/><i>[${username} entered]</i>`)
      })
    })
  }

  static sanitize(html){ return $("<div/>").text(html).html() }

  static messageTemplate(msg){
    let username = this.sanitize(msg.user || "anonymous")
    let body     = this.sanitize(msg.body)

    return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

}

$( () => App.init() )

export default App
 ```

#### Router
```elixir
defmodule Chat.Router do
  use Phoenix.Router

  socket "/ws", Chat do
    channel "rooms:*", RoomChannel
  end


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Chat do
    pipe_through :browser # Use the default browser stack

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
```
