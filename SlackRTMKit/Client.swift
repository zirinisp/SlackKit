//
// Client.swift
//
// Copyright © 2015 Peter Zignego. All rights reserved.
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

import Foundation
import Starscream

public class Client: WebSocketDelegate {
    
    public var connected = false
    public var authenticated = false
    public var authenticatedUser: User?
    public var team: Team?
    
    public var channels: [String: Channel]?
    public var users: [String: User]?
    public var bots: [String: Bot]?
    public var files: [String: File]?
    
    internal lazy var sentMessages = [String: Message]()
    
    private var token = "SLACK_AUTH_TOKEN"
    public func setAuthToken(token: String) {
        self.token = token
    }
    
    private var webSocket: WebSocket?
    
    required public init() {
        
    }
    
    public static let sharedInstance = Client()
    
    //MARK: - Connection
    public func connect() {
        let request = NSURLRequest(URL: NSURL(string:"https://slack.com/api/rtm.start?token="+token)!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.currentQueue()!) {
            (response, data, error) -> Void in
            guard let data = data else {
                return
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! Dictionary<String, AnyObject>
                if (result["ok"] as! Bool == true) {
                    self.initialSetup(result)
                    let socketURL = NSURL(string: result["url"] as! String)
                    self.webSocket = WebSocket(url: socketURL!)
                    self.webSocket?.delegate = self
                    self.webSocket?.connect()
                }
            } catch _ {
                print(error)
            }
        }
    }
    
    //MARK: - Message send
    public func sendMessage(message: String, channelID: String) {
        if (connected) {
            if let data = formatMessageToSlackJsonString(msg: message, channel: channelID) {
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                self.webSocket?.writeString(string as! String)
            }
        }
    }
    
    private func formatMessageToSlackJsonString(message: (msg: String, channel: String)) -> NSData? {
        let json: Dictionary<String, AnyObject> = [
            "id": NSDate().timeIntervalSince1970,
            "type": "message",
            "channel": message.channel,
            "text": slackFormatEscaping(message.msg)
        ]
        addSentMessage(json)
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
            return data
        }
        catch _ {
            return nil
        }
    }
    
    private func addSentMessage(dictionary:Dictionary<String, AnyObject>) {
        var message = dictionary
        let ts = message["id"] as? String
        message.removeValueForKey("id")
        message["ts"] = ts
        message["user"] = self.authenticatedUser?.id
        sentMessages?[ts!] = Message(message: message)
    }
    
    private func slackFormatEscaping(string: String) -> String {
        var escapedString = string.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("<", withString: "&lt;")
        escapedString = escapedString.stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        return escapedString
    }
    
    //MARK: - Client setup
    private func initialSetup(json: Dictionary<String, AnyObject>) {
        team = Team(team: json["team"] as? Dictionary<String, AnyObject>)
        authenticatedUser = User(user: json["self"] as? Dictionary<String, AnyObject>)
        enumerateUsers(json["users"] as? Array)
        enumerateChannels(json["channels"] as? Array)
        enumerateGroups(json["groups"] as? Array)
        enumerateDMs(json["ims"] as? Array)
        enumerateBots(json["bots"] as? Array)
    }
    
    private func enumerateUsers(users: Array<AnyObject>?) {
        self.users = [String: User]()
        for (var i=0; i < users!.count; i++) {
            let user = User(user: users?[i] as? Dictionary<String, AnyObject>)
            self.users?[user!.id!] = user
        }
    }
    
    private func enumerateChannels(channels: Array<AnyObject>?) {
        self.channels = [String: Channel]()
        for (var i=0; i < channels!.count; i++) {
            let channel = Channel(channel: channels?[i] as? Dictionary<String, AnyObject>)
            self.channels?[channel!.id!] = channel
        }
    }
    
    private func enumerateGroups(groups: Array<AnyObject>?) {
        for (var i=0; i < groups!.count; i++) {
            let group = Channel(channel: groups?[i] as? Dictionary<String, AnyObject>)
            self.channels?[group!.id!] = group
        }
    }
    
    private func enumerateDMs(dms: Array<AnyObject>?) {
        for (var i=0; i < dms!.count; i++) {
            let dm = Channel(channel: dms?[i] as? Dictionary<String, AnyObject>)
            self.channels?[dm!.id!] = dm
        }
    }
    
    private func enumerateBots(bots: Array<AnyObject>?) {
        self.bots = [String: Bot]()
        for (var i=0; i < bots?.count; i++) {
            let bot = Bot(bot: bots?[i] as? Dictionary<String, AnyObject>)
            self.bots?[bot!.id!] = bot
        }
    }
    
    // MARK: - WebSocketDelegate
    public func websocketDidConnect(socket: WebSocket) {
        print("Connected.")
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        connected = false
        authenticated = false
        webSocket = nil
        print("Disconnected: \(error)")
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {
            return
        }
        do {
            try EventDispatcher.eventDispatcher(NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String, AnyObject>)
            print(try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary)
        }
        catch _ {
            
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("Data: \(data)")
    }
    
}
