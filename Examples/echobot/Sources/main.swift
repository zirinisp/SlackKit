//
// main.swift
//
// Copyright © 2016 Peter Zignego. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SlackKit

class Echobot: MessageEventsDelegate {
    
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    // MARK: MessageEventsDelegate
    func messageReceived(message: Message) {
        listen(message: message)
    }
    
    func messageSent(message: Message){}
    func messageChanged(message: Message){}
    func messageDeleted(message: Message?){}
    
    // MARK: Echobot Internal Logic
    private func listen(message: Message) {
        if let channel = message.channel, text = message.text, id = client.authenticatedUser?.id {
            if id != message.user && message.user != nil {
                client.webAPI.sendMessage(channel:channel, text: text, linkNames: true, success: {(response) in
                    }, failure: { (error) in
                        print("Echobot failed to reply due to error:\(error)")
                })
            }
        }
    }
    
}

let echobot = Echobot(token: "xoxb-SLACK_API_TOKEN")
echobot.client.connect()