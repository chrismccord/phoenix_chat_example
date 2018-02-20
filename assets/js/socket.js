import {Socket, LongPoller} from "phoenix"

let socket = new Socket("/socket", {
  params: {user_id: "123"},
  logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
})

socket.connect()

var $status    = $("#status")
var $messages  = $("#messages")
var $input     = $("#message-input")
var $username  = $("#username")

function sanitize(html) {
  return $("<div/>").text(html).html()
}

function messageTemplate(msg){
  let username = sanitize(msg.user || "anonymous")
  let body = sanitize(msg.body)

  return(`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
}

socket.onOpen(ev => console.log("OPEN", ev))
socket.onError(ev => console.log("ERROR", ev))
socket.onClose(ev => console.log("CLOSE", ev))

let chan = socket.channel("rooms:lobby", {})

chan
  .join()
  .receive("ignore", () => console.log("auth error"))
  .receive("ok", () => console.log("join ok"))

chan.onError(e => console.log("something went wrong", e))
chan.onClose(e => console.log("channel closed", e))

chan.on("new:msg", msg => {
  $messages.append(messageTemplate(msg))
  scrollTo(0, document.body.scrollHeight)
})

chan.on("user:entered", msg => {
  var username = sanitize(msg.user || "anonymous")
  $messages.append(`<br/><i>[${username} entered]</i>`)
})

$input.off("keypress").on("keypress", e => {
  if (e.keyCode == 13) {
    chan.push("new:msg", {user: $username.val(), body: $input.val()})
    $input.val("")
  }
})

export default socket
