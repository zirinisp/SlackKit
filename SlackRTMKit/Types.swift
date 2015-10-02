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
    let user: String?
    let ts: String?
    
    internal init?(edited:Dictionary<String, AnyObject>?) {
        user = edited?["user"] as? String
        ts = edited?["ts"] as? String
    }
}

// MARK: - Reaction
public struct Reaction {
    let name: String?
    internal(set) public lazy var users = Dictionary<String, String>()
    
    internal init?(reaction:Dictionary<String, AnyObject>?) {
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
    let id: String?
    let user: String?
    internal(set) public var timestamp: String?
    internal(set) public var comment: String?
    
    internal init?(comment:Dictionary<String, AnyObject>?) {
        id = comment?["id"] as? String
        timestamp = comment?["timestamp"] as? String
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
    let type: String?
    let ts: String?
    let channel: String?
    let message: Message?
    let file: File?
    let comment: Comment?
    
    internal init?(item:Dictionary<String, AnyObject>?) {
        type = item?["type"] as? String
        ts = item?["ts"] as? String
        channel = item?["channel"] as? String
        message = Message(message: item?["message"] as? Dictionary<String, AnyObject>)
        file = File(file: item?["file"] as? Dictionary<String, AnyObject>)
        comment = Comment(comment: item?["comment"] as? Dictionary<String, AnyObject>)
    }
}

extension Item: Equatable {}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.type == rhs.type && lhs.channel == rhs.channel && lhs.file == rhs.file && lhs.comment == rhs.comment && lhs.message == rhs.message
}

// MARK: - Topic
public struct Topic {
    let value: String?
    let creator: String?
    let lastSet: String?
    
    internal init?(topic: Dictionary<String, AnyObject>?) {
        value = topic?["value"] as? String
        creator = topic?["creator"] as? String
        lastSet = topic?["last_set"] as? String
    }
}
