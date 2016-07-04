//
//  Server.swift
//  SlackKit
//
//  Created by Peter Zignego on 7/3/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation
import Swifter

public enum Reply {
    case JSON(response: Response)
    case Text(body: String)
    case Multipart(responses: [Response])
    case BadRequest
}

public struct Route {
    let path: String
    let reply: Reply
    
    public init(path: String, reply: Reply) {
        self.path = path
        self.reply = reply
    }
}

protocol Router {
    func addRoute(route: Route)
}

protocol Request {
    var responseURL: String { get }
}

public class Server {
    
    internal let http = HttpServer()
    internal let token: String
    
    internal init(token: String) {
        self.token = token
    }
    
    public func start() {
        do {
            try http.start()
        } catch let error as NSError {
            print("Server failed to start with error: \(error)")
        }
    }
    
    public func stop() {
        http.stop()
    }
    
    internal func request(request:Request, reply: Reply) -> HttpResponse {
        switch reply {
        case .Text(let body):
            return .OK(.Text(body))
        case .JSON(let response):
            return .OK(.Json(response.json()))
        case .Multipart(let responses):
            multipartResponseWith(request, responses: responses)
            return .OK(.Text("Got it!"))
        case .BadRequest:
            return .BadRequest(.Text("Bad request."))
        }
    }
    
    internal func multipartResponseWith(request: Request, responses: [Response]) {
        for response in responses {
            if let data = try? NSJSONSerialization.dataWithJSONObject(response.json(), options: []) {
                NetworkInterface().customRequest(request.responseURL, data: data, successClosure: { (response) in
                    print(response)
                }, errorClosure: { (error) in
                    print(error)
                })
            }
        }
    }
    
    internal func dictionaryFromRequest(body: [UInt8]) -> [String: AnyObject]? {
        let string = NSString(data: NSData(bytes: body, length: body.count), encoding: NSUTF8StringEncoding)
        if let body = string?.componentsSeparatedByString("&") {
            var dict: [String: AnyObject] = [:]
            for argument in body {
                let kv = argument.componentsSeparatedByString("=")
                if let key = kv.first, value = kv.last {
                    dict[key] = value
                }
            }
            return dict
        }
        return nil
    }
    
}

