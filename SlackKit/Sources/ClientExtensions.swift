//
// ClientExtensions.swift
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

import Foundation

extension Client {
    
    //MARK: - User & Channel
    public func getChannelOrUserIdByName(name: String) -> String? {
        if (name[name.startIndex] == "@") {
            return getUserIdByName(name)
        } else if (name[name.startIndex] == "C") {
            return getChannelIDByName(name)
        }
        return nil
    }
    
    public func getChannelIDByName(name: String) -> String? {
        return channels.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getUserIdByName(name: String) -> String? {
        return users.filter{$0.1.name == stripString(name)}.first?.0
    }
    
    public func getImIDForUserWithID(id: String, success: (imID: String?)->Void, failure: (error: SlackError)->Void) {
        let ims = channels.filter{$0.1.isIM == true}
        let channel = ims.filter{$0.1.user == id}.first
        if let channel = channel {
            success(imID: channel.0)
        } else {
            webAPI.openIM(id, success: success, failure: failure)
        }
    }
    
    //MARK: - Utilities
    internal func stripString(var string: String) -> String {
        if string[string.startIndex] == "@" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        } else if string[string.startIndex] == "#" {
            string = string.substringFromIndex(string.startIndex.advancedBy(1))
        }
        return string
    }
    
}

internal extension String {
    
    func slackFormatEscaping() -> String {
        var escapedString = stringByReplacingOccurrencesOfString("&", withString: "&amp;")
        escapedString = stringByReplacingOccurrencesOfString("<", withString: "&lt;")
        escapedString = stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        return escapedString
    }

}

public extension NSDate {
    
    func slackTimestamp() -> String {
        return NSNumber(double: timeIntervalSince1970).stringValue
    }

}
