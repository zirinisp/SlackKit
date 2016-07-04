//
//  Response.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/3/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

public struct Response {
    
    let responseType: ResponseType
    let text: String
    let attachments: [Attachment]?
    
    public init(responseType: ResponseType, text: String, attachments: [Attachment]? = nil) {
        self.responseType = responseType
        self.text = text
        self.attachments = attachments
    }
    
    internal func json() -> [String: AnyObject] {
        var json = [String : AnyObject]()
        json["response_type"] = responseType.rawValue
        json["text"] = text
        json["attachments"] = attachments?.flatMap({$0.dictionary()})
        return json
    }
}
