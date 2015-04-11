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
    // var socket  = new Socket("ws://" + location.host +  "/ws", {transport: Phoenix.LongPoller})
    var socket     = new Socket("ws://" + location.host +  "/ws")
    socket.connect()
    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    socket.onClose( e => console.log("CLOSE", e))

    socket.join("rooms:lobby", {})
      .receive("ignore", () => console.log("auth error") )
      .receive("ok", chan => {

        chan.onError( e => console.log("something went wrong", e) )
        chan.onClose( e => console.log("channel closed", e) )

        $input.off("keypress").on("keypress", e => {
          if (e.keyCode == 13) {
            chan.push("new:msg", {user: $username.val(), body: $input.val()})
            $input.val("")
          }
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
      .after(10000, () => console.log("Connection interruption") )
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
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    send(self, {:after_join, message})

    {:ok, socket}
  end
  def join("rooms:" <> _private_subtopic, _message, _socket) do
    :ignore
  end

  def handle_info({:after_join, msg}, socket) do
    Logger.debug "> join #{socket.topic}"
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end
  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, msg["body"]}, assign(socket, :user, msg["user"])}
  end
end
```
