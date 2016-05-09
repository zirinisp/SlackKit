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

import String
import SlackKit

class Leaderboard: MessageEventsDelegate {
    
    var leaderboard: [String: Int] = [String: Int]()
    let atSet = CharacterSet(characters: ["@"])
    
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    enum Command: String {
        case Leaderboard = "leaderboard"
    }
    
    enum Trigger: String {
        case PlusPlus = "++"
        case MinusMinus = "--"
    }
    
    // MARK: MessageEventsDelegate
    func messageReceived(message: Message) {
        listen(message: message)
    }
    
    func messageSent(message: Message){}
    func messageChanged(message: Message){}
    func messageDeleted(message: Message?){}
    
    // MARK: Leaderboard Internal Logic
    private func listen(message: Message) {
        if let id = client.authenticatedUser?.id, text = message.text {
            if text.lowercased().contains(query: Command.Leaderboard.rawValue) && text.contains(query: id) {
                handleCommand(command: .Leaderboard, channel: message.channel)
            }
        }
        if message.text?.contains(query: Trigger.PlusPlus.rawValue) == true {
            handleMessageWithTrigger(message: message, trigger: .PlusPlus)
        }
        if message.text?.contains(query: Trigger.MinusMinus.rawValue) == true {
            handleMessageWithTrigger(message: message, trigger: .MinusMinus)
        }
    }
    
    private func handleMessageWithTrigger(message: Message, trigger: Trigger) {
        if let text = message.text,
        start = text.index(of: "@"),
        end = text.index(of: trigger.rawValue) {
            let string = String(text.characters[start...end].dropLast().dropFirst())
            let users = client.users.values.filter{$0.id == self.userID(string: string)}
            if users.count > 0 {
                let idString = userID(string: string)
                initalizationForValue(dictionary: &leaderboard, value: idString)
                scoringForValue(dictionary: &leaderboard, value: idString, trigger: trigger)
            } else {
                initalizationForValue(dictionary: &leaderboard, value: string)
                scoringForValue(dictionary: &leaderboard, value: string, trigger: trigger)
            }
        }
    }
    
    private func handleCommand(command: Command, channel:String?) {
        switch command {
        case .Leaderboard:
            if let id = channel {
                client.webAPI.sendMessage(channel:id, text: "Leaderboard", linkNames: true, attachments: [constructLeaderboardAttachment()], success: {(response) in
                    
                    }, failure: { (error) in
                        print("Leaderboard failed to post due to error:\(error)")
                })
            }
        }
    }
    
    private func initalizationForValue( dictionary: inout [String: Int], value: String) {
        if dictionary[value] == nil {
            dictionary[value] = 0
        }
    }
    
    private func scoringForValue( dictionary: inout [String: Int], value: String, trigger: Trigger) {
        switch trigger {
        case .PlusPlus:
            dictionary[value]?+=1
        case .MinusMinus:
            dictionary[value]?-=1
        }
    }
    
    // MARK: Leaderboard Interface
    private func constructLeaderboardAttachment() -> Attachment? {
        let 💯 = AttachmentField(title: "💯", value: swapIDsForNames(string: topItems(dictionary: &leaderboard)), short: true)
        let 💩 = AttachmentField(title: "💩", value: swapIDsForNames(string: bottomItems(dictionary: &leaderboard)), short: true)
        return Attachment(fallback: "Leaderboard", title: "Leaderboard", colorHex: AttachmentColor.Good.rawValue, text: "", fields: [💯, 💩])
    }
    
    private func topItems(dictionary: inout [String: Int]) -> String {
        let sortedKeys = dictionary.keys.sorted(isOrderedBefore: ({dictionary[$0] > dictionary[$1]})).filter({dictionary[$0] > 0})
        let sortedValues = dictionary.values.sorted(isOrderedBefore: {$0 > $1}).filter({$0 > 0})
        return leaderboardString(keys: sortedKeys, values: sortedValues)
    }
    
    private func bottomItems( dictionary: inout [String: Int]) -> String {
        let sortedKeys = dictionary.keys.sorted(isOrderedBefore: ({dictionary[$0] < dictionary[$1]})).filter({dictionary[$0] < 0})
        let sortedValues = dictionary.values.sorted(isOrderedBefore: {$0 < $1}).filter({$0 < 0})
        return leaderboardString(keys: sortedKeys, values: sortedValues)
    }
    
    private func leaderboardString(keys: [String], values: [Int]) -> String {
        var returnValue = ""
        for i in 0..<values.count {
            returnValue += keys[i] + " (" + "\(values[i])" + ")\n"
        }
        return returnValue
    }
    
    // MARK: - Utilities
    private func swapIDsForNames(string: String) -> String {
        var returnString = string
        for key in client.users.keys {
            if let name = client.users[key]?.name {
                if returnString.contains(query: key) {
                    returnString.replace(string: key, with: "@"+name)
                }
            }
        }
        return returnString
    }
    
    private func userID(string: String) -> String {
        let alphanumericSet = CharacterSet(characters:
                              ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
                               "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                               "0","1","2","3","4","5","6","7","8","9"])
        return string.trim(alphanumericSet.inverted)
    }
}

let leaderboard = Leaderboard(token: "xoxb-SLACK_API_TOKEN")
leaderboard.client.connect()