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

class RobotOrNotBot: MessageEventsDelegate {
    
    let verdicts: [String:Bool] = [
                                      "Mr. Roboto" : false,
                                      "Service Kiosks": false,
                                      "Darth Vader": false,
                                      "K-9": true,
                                      "Emotions": false,
                                      "Self-Driving Cars": false,
                                      "Telepresence Robots": false,
                                      "Roomba": true,
                                      "Assembly-Line Robot": false,
                                      "ASIMO": false,
                                      "KITT": false,
                                      "USS Enterprise": false,
                                      "Transformers": true,
                                      "Jaegers": false,
                                      "The Major": false,
                                      "Siri": false,
                                      "The Terminator": true,
                                      "Commander Data": false,
                                      "Marvin the Paranoid Android": true,
                                      "Pinocchio": false,
                                      "Droids": true,
                                      "Hitchbot": false,
                                      "Mars Rovers": false,
                                      "Space Probes": false,
                                      "Sasquatch": false,
                                      "Toaster": false,
                                      "Toaster Oven": false,
                                      "Cylons": false,
                                      "V'ger": true,
                                      "Ilia Robot": false,
                                      "The TARDIS": false,
                                      "Johnny 5": true,
                                      "Twiki": true,
                                      "Dr. Theopolis": false,
                                      "robots.txt": false,
                                      "Lobot": false,
                                      "Vicki": true,
                                      "GlaDOS": false,
                                      "Turrets": true,
                                      "Wheatley": true,
                                      "Herbie the Love Bug": false,
                                      "Iron Man": false,
                                      "Ultron": false,
                                      "The Vision": false,
                                      "Clockwork Droids": false,
                                      "Podcasts": false,
                                      "Cars": false,
                                      "Swimming Pool Cleaners": false,
                                      "Burritos": false,
                                      "Prince Robot IV": false,
                                      "Daleks": false,
                                      "Cybermen": false,
                                      "The Internet of Things": false,
                                      "Nanobots": true,
                                      "Two Intermeshed Gears": false,
                                      "Crow T. Robot": true,
                                      "Tom Servo": true,
                                      "Thomas and Friends": false,
                                      "Replicants": false,
                                      "Chatbots": false,
                                      "Agents": false,
                                      "Lego Simulated Worm Toy": true,
                                      "Ghosts": false,
                                      "Exos": true,
                                      "Rasputin": false,
                                      "Tamagotchi": false,
                                      "T-1000": true,
                                      "The Tin Woodman": false,
                                      "Mic N. The Robot": true,
                                      "Robot Or Not Bot": false
    ]
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    // MARK: MessageEventsDelegate
    func messageReceived(message: Message) {
        if let id = client.authenticatedUser?.id {
            if message.text?.contains(query: id) == true {
                handleMessage(message: message)
            }
        }
    }
    
    func messageSent(message: Message){}
    func messageChanged(message: Message){}
    func messageDeleted(message: Message?){}
    
    private func handleMessage(message: Message) {
        if let text = message.text?.lowercased(), channel = message.channel {
            for (robot, verdict) in verdicts {
                let lowerbot = robot.lowercased()
                if text.contains(query: lowerbot) {
                    if verdict == true {
                        client.webAPI.addReaction(name: "robot_face", timestamp: message.ts, channel: channel, success: nil, failure: nil)
                    } else {
                        client.webAPI.addReaction(name: "no_entry_sign", timestamp: message.ts, channel: channel, success: nil, failure: nil)
                    }
                    return
                }
            }
            client.webAPI.addReaction(name: "question", timestamp: message.ts, channel: channel, success: nil, failure: nil)
        }
    }
}

let slackbot = RobotOrNotBot(token: "xoxb-SLACK_API_TOKEN")
slackbot.client.connect()