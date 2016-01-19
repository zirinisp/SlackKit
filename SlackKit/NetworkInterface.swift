//
//  NetworkInterface.swift
//  SlackKit
//
//  Created by Peter Zignego on 1/18/16.
//  Copyright © 2016 Launch Software LLC. All rights reserved.
//

import Foundation

public struct NetworkInterface {
    
    private let apiUrl = "https://slack.com/api/"
    
    internal func request(endpoint: SlackAPIEndpoint, parameters: [String: AnyObject]?, json: ([String: AnyObject]) -> Void) {
        let token = Client.sharedInstance.token
        var requestString = "\(apiUrl)\(endpoint.rawValue)?token=\(token)"
        if let params = parameters {
            requestString = requestString + requestStringFromParameters(params)
        }
        let request = NSURLRequest(URL: NSURL(string: requestString)!)
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            guard let data = data else {
                return
            }
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                if (result["ok"] as! Bool == true) {
                    json(result)
                } else {
                    //Error
                }
            } catch _ {
                print(error)
            }
        }.resume()
    }
    
    private func requestStringFromParameters(parameters: [String: AnyObject]) -> String {
        var requestString = ""
        for key in parameters.keys {
            if let value = parameters[key] as? String {
                requestString = requestString + "&\(key)=\(value)"
            }
        }
        
        return requestString
    }
}
