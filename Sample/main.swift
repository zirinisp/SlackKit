import SlackKit

class MyBot: SlackEventsDelegate {
    
    let client = Client(apiToken: "xoxp-2173475134-2173475136-9612478055-8e3455")

    init() {
        client.slackEventsDelegate = self
        client.connect()
        let reply = Reply.Text(body: "Hello, world!")
        let route = Route(path: "actions", reply: reply)
        let messages = MessageActionServer(token: "B8wJwoNKckMe13a07iBjOMvT", route: route)
        messages.start()
    }
    
    func clientConnected() {
        let action = Action(name: "Action", text: "Action")
        let attachment = Attachment(fallback: "test", title: "test", callbackID: "callback", actions: [action])
        client.webAPI.sendMessage(try! client.getChannelIDByName("test-channel"), text: "test", attachments: [attachment], success: { (response) in
            //print(response)
        }) {(error) in
            print(error)
        }
    }
    
    func clientConnectionFailed(error: SlackError) {}
    func clientDisconnected() {}
    func preferenceChanged(preference: String, value: AnyObject?) {}
    func userChanged(user: User) {}
    func presenceChanged(user: User, presence: String) {}
    func manualPresenceChanged(user: User, presence: String) {}
    func botEvent(bot: Bot) {}

}

let myBot = MyBot()
NSRunLoop.mainRunLoop().run()

//let reply = Reply.Text(body: "Hello, world!")
//let response = Response(responseType: .Ephemeral, text: "Hello!")
//let reply = Reply.Multipart(responses: [response, response, response, response, response])
//let route = Route(path:"hello", reply: reply)
//let webhook = Webhook(token: "uAZTu3hxICQBlezVbKHDAbjt", route: route)
//webhook.start()
