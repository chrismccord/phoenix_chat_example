import {Socket, LongPoller} from "phoenix"

class App {

  static init(){
    let socket = new Socket("/socket", {params: {token: window.userToken}, 
                                        logger: ((kind, msg, data) => {console.log('${kind}: ${msg}', data)})})
    // let socket = new Socket("/socket", {
    //   logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
    // })

    var $status    = $("#status")
    var $messages  = $("#messages")
    var $input     = $("#message-input")
    var $username  = $("#username")

    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    // Finally, connect to the socket:
    let channel           = socket.channel("room:lobby", {})
    let chatInput         = document.querySelector("#message-input")
    let messagesContainer = document.querySelector("#messages")
    
    socket.connect({user_id: "abcd"})
    
    chatInput.addEventListener("keypress", event => {
      if(event.key === 'Enter'){
        channel.push("new_msg", {body: chatInput.value})
        chatInput.value = ""
      }
    })

    var chan = socket.channel("rooms:lobby", {})
    chan.join().receive("ok", () => console.log("join ok"))
               .receive("ignore", () => console.log("auth error"))
               // .after(10000, () => console.log("Connection interruption"))
    chan.onError(e => console.log("something went wrong", e))
    chan.onClose(e => console.log("channel closed", e))

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
