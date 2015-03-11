import {Socket, LongPoller} from "phoenix"

class App {

  static init(){
    // var socket  = new Socket("ws://" + location.host +  "/ws", {transport: Phoenix.LongPoller})
    var socket     = new Socket("ws://" + location.host +  "/ws")
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
