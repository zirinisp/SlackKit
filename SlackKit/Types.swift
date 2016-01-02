//
// Types.swift
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

// MARK: - Edited
public struct Edited {
    public let user: String?
    public let ts: String?
    
    internal init?(edited:[String: AnyObject]?) {
        user = edited?["user"] as? String
        ts = edited?["ts"] as? String
    }
}

// MARK: - Reaction
public struct Reaction {
    public let name: String?
    internal(set) public var users = [String: String]()
    
    internal init?(reaction:[String: AnyObject]?) {
        name = reaction?["name"] as? String
    }
    
    internal init?(name: String?, user: String) {
        self.name = name
        users[user] = user
    }
}

extension Reaction: Equatable {}

public func ==(lhs: Reaction, rhs: Reaction) -> Bool {
    return lhs.name == rhs.name
}

// MARK: - Comment
public struct Comment {
    public let id: String?
    public let user: String?
    internal(set) public var timestamp: Int?
    internal(set) public var comment: String?
    
    internal init?(comment:[String: AnyObject]?) {
        id = comment?["id"] as? String
        timestamp = comment?["timestamp"] as? Int
        user = comment?["user"] as? String
        self.comment = comment?["comment"] as? String
    }
    
    internal init?(id: String?) {
        self.id = id
        self.comment = nil
        self.timestamp = nil
        self.user = nil
    }
}

extension Comment: Equatable {}

public func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
}

// MARK: - Item
public struct Item {
    public let type: String?
    public let ts: String?
    public let channel: String?
    public let message: Message?
    public let file: File?
    public let comment: Comment?
    
    internal init?(item:[String: AnyObject]?) {
        type = item?["type"] as? String
        ts = item?["ts"] as? String
        channel = item?["channel"] as? String
        message = Message(message: item?["message"] as? [String: AnyObject])
        file = File(file: item?["file"] as? [String: AnyObject])
        comment = Comment(comment: item?["comment"] as? [String: AnyObject])
    }
}

extension Item: Equatable {}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.type == rhs.type && lhs.channel == rhs.channel && lhs.file == rhs.file && lhs.comment == rhs.comment && lhs.message == rhs.message
}

// MARK: - Topic
public struct Topic {
    public let value: String?
    public let creator: String?
    public let lastSet: Int?
    
    internal init?(topic: [String: AnyObject]?) {
        value = topic?["value"] as? String
        creator = topic?["creator"] as? String
        lastSet = topic?["last_set"] as? Int
    }
}

// MARK: - Do Not Disturb Status
public struct DoNotDisturbStatus {
    internal(set) public var enabled: Bool?
    internal(set) public var nextDoNotDisturbStart: Int?
    internal(set) public var nextDoNotDisturbEnd: Int?
    internal(set) public var snoozeEnabled: Bool?
    internal(set) public var snoozeEndtime: Int?
    
    internal init?(status: [String: AnyObject]?) {
        enabled = status?["dnd_enabled"] as? Bool
        nextDoNotDisturbStart = status?["next_dnd_start_ts"] as? Int
        nextDoNotDisturbEnd = status?["next_dnd_end_ts"] as? Int
        snoozeEnabled = status?["snooze_enabled"] as? Bool
        snoozeEndtime = status?["snooze_endtime"] as? Int
    }
    
}
