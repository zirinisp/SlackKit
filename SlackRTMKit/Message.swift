//
// Message.swift
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

public enum ItemType: String {
    case ChannelMessage = "C"
    case PrivateGroupMessage = "G"
    case File = "F"
    case FileComments = "Fc"
}

public class Message {

    let type = "message"
    let subtype: String?
    var ts: String?
    let user: String?
    let channel: String?
    let hidden: Bool?
    internal(set) public var text: String?
    let botID: String?
    let username: String?
    let icons: Dictionary<String, AnyObject>?
    let deletedTs: String?
    let purpose: String?
    let topic: String?
    let name: String?
    let members: [String]?
    let oldName: String?
    let upload: Bool?
    let itemType: String?
    internal(set) public var isStarred: Bool?
    let pinnedTo: [String]?
    let comment: Comment?
    let file: File?
    internal(set) public lazy var reactions = Dictionary<String, Reaction>()
    
    init?(message: Dictionary<String, AnyObject>?) {
        subtype = message?["subtype"] as? String
        ts = message?["ts"] as? String
        user = message?["user"] as? String
        channel = message?["channel"] as? String
        hidden = message?["hidden"] as? Bool
        text = message?["text"] as? String
        botID = message?["bot_id"] as? String
        username = message?["username"] as? String
        icons = message?["icons"] as? Dictionary<String, AnyObject>
        deletedTs = message?["deleted_ts"] as? String
        purpose = message?["purpose"] as? String
        topic = message?["topic"] as? String
        name = message?["name"] as? String
        members = message?["members"] as? [String]
        oldName = message?["old_name"] as? String
        upload = message?["upload"] as? Bool
        itemType = message?["item_type"] as? String
        isStarred = message?["is_starred"] as? Bool
        pinnedTo = message?["pinned_to"] as? [String]
        comment = Comment(comment: message?["comment"] as? Dictionary<String, AnyObject>)
        file = File(file: message?["file"] as? Dictionary<String, AnyObject>)
        if let messageReactions = message?["reactions"] as? [Dictionary<String, AnyObject>] {
            for react in messageReactions {
                let reaction = Reaction(reaction: react)
                self.reactions[reaction!.name!] = reaction
            }
        }
    }
}

extension Message: Equatable {}

public func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.ts == rhs.ts && lhs.user == rhs.user && lhs.text == rhs.text
}
