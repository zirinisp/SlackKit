//
// Extensions.swift
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

public extension Date {

    var slackTimestamp: Double {
        return NSNumber(value: timeIntervalSince1970).doubleValue
    }
}

internal extension String {
    
    var slackFormatEscaping: String {
        var escapedString = replacingOccurrences(of: "&", with: "&amp;")
        escapedString = replacingOccurrences(of: "<", with: "&lt;")
        escapedString = replacingOccurrences(of: ">", with: "&gt;")
        return escapedString
    }
}

internal extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    var requestStringFromParameters: String {
        var requestString = ""
        for key in self.keys {
            if let value = self[key] as? String, let encodedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) {
                requestString += "&\(key)=\(encodedValue)"
            } else if let value = self[key] as? Int {
                requestString += "&\(key)=\(value)"
            }
        }
        
        return requestString
    }
}

